# Mixin. Expects that target class implements:
#  - answer_text (returns string)
#  - c_rater_settings (should point to CRaterSettings instance if feedback should be obtained, nil otherwise)

module CRater::FeedbackFunctionality
  extend ActiveSupport::Concern
  include Embeddable::FeedbackFunctionality

  # Overwrite Embeddable::FeedbackFunctionality association:
  included do
    has_many :feedback_items, as: :answer, class_name: 'CRater::FeedbackItem'
  end

  # Overwrite Embeddable::FeedbackFunctionality method:
  def save_feedback
    return nil if answer_text.blank?
    request_c_rater_feedback
  end

  # New methods:
  def c_rater_config
    {
      client_id: ENV['C_RATER_CLIENT_ID'],
      username:  ENV['C_RATER_USERNAME'],
      password:  ENV['C_RATER_PASSWORD'],
      url:       ENV['C_RATER_URL'] # optional, APIWrapper will use default URL if not provided.
    }
  end

  def c_rater_enabled?
    !!c_rater_configured? && !!c_rater_settings && !!c_rater_settings.item_id
  end

  private

  def c_rater_configured?
    config = c_rater_config
    !!config[:client_id] && !!config[:username] && !!config[:password]
  end

  def request_c_rater_feedback(options = {})
    return unless c_rater_enabled?
    feedback_item = CRater::FeedbackItem.new(
      status: CRater::FeedbackItem::STATUS_REQUESTED,
      # Save both answer text and item id to prevent context loss - these values can be changed later by user.
      answer_text: answer_text,
      item_id: c_rater_settings.item_id
    )
    feedback_item.answer = self
    if options[:async]
      feedback_item.save!
      delay.continue_feedback_processing(feedback_item)
    else
      continue_feedback_processing(feedback_item)
    end
    feedback_item
  end

  def continue_feedback_processing(feedback_item)
    response = issue_c_rater_request(feedback_item)
    if response[:success]
      feedback_item.status = CRater::FeedbackItem::STATUS_SUCCESS
      feedback_item.score = response[:score]
      # TODO: score -> text mapping
      # Use dummy "Score: <value>" text for now.
      feedback_item.feedback_text = "Score: #{response[:score]}"
    else
      feedback_item.status = CRater::FeedbackItem::STATUS_ERROR
      feedback_item.feedback_text = response[:error]
    end
    feedback_item.response_info = response[:response_info]
    feedback_item.save!
  end

  def issue_c_rater_request(feedback_item)
    config = c_rater_config
    crater = CRater::APIWrapper.new(config[:client_id], config[:username], config[:password], config[:url])
    # Use answer.id (as answer class includes this module) as response_id provided to C-Rater.
    crater.get_feedback(feedback_item.item_id, id, feedback_item.answer_text)
  end
end
