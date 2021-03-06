text_fields = {
  "InteractivePage" => [
    :text,
    :name,
    :sidebar,
    :sidebar_title
  ],
  "ImageInteractive" => [
    :caption,
    :credit
  ],
  "LightweightActivity" => [
    :name,
    :description,
    :notes
  ],
  "MwInteractive" => [
    :name,
    :url,
    :image_url
  ],
  "Sequence" => [
    :description,
    :title,
    :display_title
  ],
  "VideoInteractive" => [
    :caption,
    :credit,
    :poster_url
  ],
  "VideoSource" => [
    :url
  ],
  "Embeddable::Xhtml" => [
    :name,
    :content
  ],
  "Embeddable::OpenResponse" => [
    :name,
    :prompt,
    :hint,
    :prediction_feedback,
    :default_text
  ],
  "Embeddable::MultipleChoice" => [
    :name,
    :prompt,
    :hint,
    :prediction_feedback
  ],
  "Embeddable::MultipleChoiceChoice" => [
    :choice,
    :prompt
  ],
  "Embeddable::Labbook" => [
    :name,
    :prompt,
    :hint
  ],
  "Embeddable::ImageQuestion" => [
    :name,
    :prompt,
    :hint,
    :drawing_prompt,
    :prediction_feedback
  ]
}

interactive_url_field = {
  "MwInteractive" => [
    :url
  ]
}

def find_text(model_class, field_name, text)
  model_class.constantize.where("#{field_name} like '%#{text}%'")
end

def replace_text(model, field_name, text, replacement)
  old_text = model.send(field_name.to_s)
  new_text = old_text.gsub(text, replacement)
  model.send("#{field_name}=".to_s, new_text)
  puts "+ replacing text of #{model.class.name}(#{model.id})##{field_name}"
  begin
    model.save!
  rescue
    puts "- failed to save #{model.class.name}(#{model.id})##{field_name}"
  end
end

def print_results(results, field_name, text)
  results.each do |model|
    found_text = model.send(field_name.to_s)
    highlighted = found_text.gsub(text,"\e[1m\\0\e[0m")
    puts "------------------"
    puts "#{model.class.name}(#{model.id})##{field_name} #{highlighted}"
  end
  nil
end

def matching_text(results, field_name, text, ending_character)
  matches = []
  results.each do |model|
    found_text = model.send(field_name.to_s)
    matches += found_text.scan(/#{text}[^#{ending_character}]*/)
  end
  matches
end

def find_and_print_all(text_fields, text)
  total = 0
  text_fields.each do |model_class, fields|
    fields.each do |field_sym|
      results = find_text(model_class, field_sym.to_s, text)
      total+= results.count
      print_results(results, field_sym.to_s, text)
    end
  end
  puts "------------"
  puts "Total Found: #{total}"
end

def find_all_unqiue_matches(text_fields, text, ending_character)
  matches = []
  text_fields.each do |model_class, fields|
    fields.each do |field_sym|
      results = find_text(model_class, field_sym.to_s, text)
      matches += matching_text(results, field_sym.to_s, text, ending_character)
    end
  end
  matches.uniq.sort
end

# https://s3.amazonaws.com/itsi-production/images-2009
# find_and_replace_all(text_fields, "http://itsi.portal.concord.org/system/images", "https://s3.amazonaws.com/itsi-production/images-2009")
def find_and_replace_all(text_fields, text, replacement)
  total = 0
  text_fields.each do |model_class, fields|
    fields.each do |field_sym|
      results = find_text(model_class, field_sym.to_s, text)
      puts "Found #{results.count} in #{model_class}##{field_sym.to_s}"
      total+= results.count
      results.each do |model|
        replace_text(model, field_sym.to_s, text, replacement)
      end
    end
  end
  puts "Total Found: #{total}"
end

# might not work, haven't tried this yet
interactives = MwInteractive.where("url like '%http://%'"); nil

interactives = find_text("MwInteractive", :url, "http://"); nil
interactives = interactives.all.select{|i| i.interactive_page}; nil

402 intearctives with http URLs
391 of these have interactie_page objects and lightweight_activity objects

def interactive_info(i)
  info = [];
  (2013..2017).each{|year|
    info << i.interactive_page.lightweight_activity.runs.where(updated_at: Date.new(year)..Date.new(year+1)).count
  }
  info << i.interactive_page.lightweight_activity.runs.where(updated_at: Date.new(2018)..Date.today).count

  info << i.interactive_page.lightweight_activity.runs.count
  info << i.id
  info << i.interactive_page.lightweight_activity.id
  info << i.url
  info
end

results = interactives.map{|i| interactive_info(i)}; nil
results = interactives.map{|i| [i.interactive_page.lightweight_activity.runs.count, i.id, i.interactive_page.lightweight_activity.id, i.url]}

puts results.inject([]) { |csv, row|  csv << CSV.generate_line(row) }.join(""); nil
