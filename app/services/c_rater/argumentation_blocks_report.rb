module CRater::ArgumentationBlocksReport

  require 'nokogiri'
  require 'spreadsheet'
  Spreadsheet.client_encoding = 'UTF-8'

  def self.generate(arg_block_buckets)
    bucket_columns = arg_block_buckets[:columns].map &:to_sym
    bucket_rows = arg_block_buckets[:rows]
    bucket_row_indices = indices_by_element(bucket_columns)

    bucket_index_by_remote_endpoint = {}
    all_remote_endpoints = []

    bucket_rows.each_with_index do |row, index|
      row[bucket_row_indices[:remote_endpoint]].each do |endpoint|
        bucket_index_by_remote_endpoint[endpoint] = index
        all_remote_endpoints.push(endpoint)
      end
    end

    select_params = [
      {
        :embeddable_type => "Embeddable::OpenResponse",
        :embeddable_table => "embeddable_open_responses",
        :answer_table => "embeddable_open_response_answers",
        :question_foreign_key => "open_response_id",
        :feedback_table => "c_rater_feedback_items"
      },
      {
        :embeddable_type => "Embeddable::MultipleChoice",
        :embeddable_table => "embeddable_multiple_choices",
        :answer_table => "embeddable_multiple_choice_answers",
        :question_foreign_key => "multiple_choice_id",
        :feedback_table => "embeddable_feedback_items"
      }
    ]

    selects = select_params.map do |s|
      select = <<SQL
        SELECT DISTINCT
        runs.remote_endpoint                          AS remote_endpoint,
        c_rater_feedback_submissions.created_at       AS submission_time,
        c_rater_feedback_submissions.id               AS submission_id,
        lightweight_activities.name                   AS activity_name,
        lightweight_activities.id                     AS activity_id,
        interactive_pages.name                        AS page_name,
        interactive_pages.id                          AS page_id,
        page_items.position                           AS question_index,
        #{s[:embeddable_table]}.id                    AS question_id,
        #{s[:embeddable_table]}.prompt                AS prompt,
        #{s[:feedback_table]}.answer_text             AS answer,
        #{s[:feedback_table]}.score                   AS score,
        #{s[:feedback_table]}.feedback_text           AS feedback,
        c_rater_feedback_submissions.usefulness_score AS usefulness_score
      FROM runs
        INNER JOIN lightweight_activities
          ON lightweight_activities.id = runs.activity_id
        INNER JOIN interactive_pages
          ON interactive_pages.lightweight_activity_id = lightweight_activities.id
        INNER JOIN page_items
          ON page_items.interactive_page_id = interactive_pages.id
        INNER JOIN #{s[:embeddable_table]}
          ON #{s[:embeddable_table]}.id = page_items.embeddable_id
        INNER JOIN #{s[:answer_table]}
          ON #{s[:answer_table]}.run_id = runs.id AND #{s[:answer_table]}.#{s[:question_foreign_key]} = #{s[:embeddable_table]}.id
        INNER JOIN #{s[:feedback_table]}
          ON #{s[:feedback_table]}.answer_id = #{s[:answer_table]}.id
        INNER JOIN c_rater_feedback_submissions
          ON c_rater_feedback_submissions.id = #{s[:feedback_table]}.feedback_submission_id
      WHERE
        page_items.section = "arg_block"
        AND
        embeddable_type = "#{s[:embeddable_type]}"
        AND
        remote_endpoint in ("#{all_remote_endpoints.join('","')}")
SQL
    end

    # Result rows must be (1) ordered by submission_time, with (2) successive rows from the same
    # feedback submission appearing contiguously. The submission_time values of all rows from a
    # given submission will be identical, becaause they come from the same row in the submissions
    # table. Sort secondarily by submssion_id to ensure contiguity in the unlikely case two
    # submissions have an exactly identical submission_time.

    order_by = <<SQL
      ORDER BY
        submission_time,
        submission_id
SQL

    sql = selects.join("\n UNION\n") + order_by + ";"
    result = ActiveRecord::Base.connection.exec_query(sql)
    result_columns = result.columns.map &:to_sym
    result_row_indices = indices_by_element(result_columns)

    result_rows_by_bucket_index = Array.new(bucket_rows.length) { [] }  # ensure *distinct* empty arrays
    question_indices_by_page_id = {}

    # some columns have to have html formatting stripped
    columns_indices_to_clean = [:prompt, :answer, :feedback].map { |c| result_row_indices[c] }

    # 1. Divvy results into buckets, preserving existing result ordering within each bucket
    # 2. Keep track of all question_index values seen for each page, so that we can normalize them
    #    to 0..3 in order to place question, answer, score, and feedback into the correct column.
    #    (question_indexes indicate relative order, but may have gaps. Furthermore, because feedback
    #    items aren't saved when a student leaves the corresponding question blank, when we process
    #    results for just one submission we might not know which columns to skip, unless we keep
    #    track of all questions (seen in the report) for that page.

    result.rows.each do |row|
      # strip formatting
      columns_indices_to_clean.each do |col_idx|
        row[col_idx] = clean_value(row[col_idx])
      end

      endpoint = row[result_row_indices[:remote_endpoint]]
      rows = result_rows_by_bucket_index[bucket_index_by_remote_endpoint[endpoint]]
      rows.push(row)

      page_id = row[result_row_indices[:page_id]]
      question_index = row[result_row_indices[:question_index]]
      question_indices_by_page_id[page_id] ||= Set.new
      question_indices_by_page_id[page_id].add(question_index)
    end

    # Create a hash of hashes that normalize question_index values into the range 0..3
    question_index_map_by_page_id = {}
    question_indices_by_page_id.keys.each do |page_id|
      # get an array of all question_index values we've seen on this page (e.g., [1, 5, 6, 10])
      observed_index_list = question_indices_by_page_id[page_id].to_a
      # turn the array into a hash like { 1 => 0, 5 => 1, 6 => 2, 10 => 3 }
      question_index_map_by_page_id[page_id] = indices_by_element(observed_index_list)
    end

    # All buckets are filled and all question indices are found; we can populate the spreadsheet

    header_name_for_sql_column = {
      :permission_forms => "Permission Form(s)",
      :teachers_name    => "Teacher Name",
      :school_name      => "School Name",
      :class_id         => "Class ID",
      :student_id       => "Student ID",
      :submission_time  => "Submission Date & Time",
      :activity_name    => "Activity Name",
      :activity_id      => "Activity ID",
      :page_name        => "Page Name",
      :page_id          => "Page ID",
      :question_id      => "Question ID",
      :prompt           => "Prompt",
      :answer           => "Answer",
      :score            => "Score",
      :feedback         => "Feedback",
      :usefulness_score => "Usefulness Score"
    }

    header_name = Proc.new do |column|
      header_name_for_sql_column[column]
    end

    num_questions = 4

    bucket_prefix_columns = bucket_columns.reject { |h| h == :remote_endpoint }
    result_prefix_columns = [:submission_time, :activity_name, :activity_id, :page_name, :page_id]
    detail_columns = [:question_id, :prompt, :answer, :score, :feedback]
    suffix_columns = [:usefulness_score]

    detail_start_index = bucket_prefix_columns.length + result_prefix_columns.length
    suffix_start_index = bucket_prefix_columns.length + result_prefix_columns.length + num_questions * detail_columns.length

    # Create a spreadsheet and the main ("long format", i.e., not broken-out) worksheet within it
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet :name => 'Long Format'

    # Add header row
    header_row = sheet.row(0)

    push_header = Proc.new do |header|
      header_row.push(header)
    end

    (bucket_prefix_columns + result_prefix_columns).map(&header_name).each(&push_header)
    num_questions.times do |i|
      detail_columns.map(&header_name).map { |h| h + " (#{i+1})" }.each(&push_header)
    end
    suffix_columns.map(&header_name).each(&push_header)

    # Add rows for submissions, in bucket order
    row_index = 1
    bucket_rows.each_with_index do |bucket_row, bucket_index|
      row = nil
      previous_submission_id = nil
      result_rows_by_bucket_index[bucket_index].each do |result_row|
        # create a new spreadsheet row for every submission. Submissions should always occupy
        # consecutive result_rows, and should never span buckets (which correspond to different students!)
        unless result_row[result_row_indices[:submission_id]] == previous_submission_id
          previous_submission_id = result_row[result_row_indices[:submission_id]]
          row = sheet.row(row_index)
          row_index += 1

          bucket_prefix_columns.each do |column|
            row.push(bucket_row[bucket_row_indices[column]])
          end
          result_prefix_columns.each do |column|
            row.push(result_row[result_row_indices[column]])
          end

          # leave room in the middle for detail columns
          suffix_columns.each_with_index do |column, index|
            row[suffix_start_index + index] = result_row[result_row_indices[column]]
          end
        end

        # populate the "detail" (per-question) columns
        page_id = result_row[result_row_indices[:page_id]]
        question_index = result_row[result_row_indices[:question_index]]
        normalized_question_index = question_index_map_by_page_id[page_id][question_index]
        start_index = detail_start_index + normalized_question_index * detail_columns.length

        detail_columns.each_with_index do |column, index|
          row[start_index + index] = result_row[result_row_indices[column]]
        end
      end
    end

    book
  end

  def self.clean_value(value)
    value.class == String ? clean_text(value) : value
  end

  def self.clean_text(text)
    Nokogiri::HTML(text).inner_text
  end

  def self.indices_by_element(array)
    Hash[(0...array.length).zip(array)].invert
  end
end
