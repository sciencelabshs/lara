class Run < ActiveRecord::Base
  attr_accessible :run_count, :user_id, :key, :activity, :user, :remote_id, :remote_endpoint, :activity_id, :sequence_id

  belongs_to :activity, :class_name => LightweightActivity

  belongs_to :user

  belongs_to :page, :class_name => InteractivePage # last page

  belongs_to :sequence # optional

  belongs_to :sequence_run # optional

  has_many :multiple_choice_answers,
    :class_name  => 'Embeddable::MultipleChoiceAnswer',
    :foreign_key => 'run_id',
    :dependent   => :destroy

  has_many :open_response_answers,
    :class_name  => 'Embeddable::OpenResponseAnswer',
    :foreign_key => 'run_id',
    :dependent => :destroy

  has_many :image_question_answers,
    :class_name  => 'Embeddable::ImageQuestionAnswer',
    :foreign_key => 'run_id',
    :dependent => :destroy

  before_validation :check_key

  scope :by_key, lambda { |k|
      {:conditions => { :key => k } }
    }

  validates :key,
    :format => { :with => /\A[a-zA-Z0-9\-]*\z/ },
    :length => { :is => 36 }

  def check_key
    unless key.present?
      self.key = session_guid
    end
  end

  # Generates a GUID for a particular run of an activity
  def session_guid
    UUIDTools::UUID.random_create.to_s
  end


  def self.for_user_and_portal(user,activity,portal)
    conditions = {
      remote_endpoint: portal.remote_endpoint,
      remote_id:       portal.remote_id,
      user_id:         user.id
      #TODO: add domain
    }
    conditions[:activity_id]     = activity.id if activity
    found = self.find(:first, :conditions => conditions)
    return found || self.create(conditions)
  end

  def self.for_user_and_activity(user,activity)
    conditions = {
      activity_id:     activity.id,
      user_id:         user.id
    }
    found = self.find(:first, :conditions => conditions)
    return found || self.create(conditions)
  end

  def self.for_key(key, activity)
    self.by_key(key).first || self.create(activity: activity)
  end

  def self.lookup(key, activity, user, portal)
    return self.for_user_and_portal(user, activity, portal) if user && portal && portal.valid?
    return self.for_key(key, activity) if (key && activity)
    return self.for_user_and_activity(user,activity) if (user && activity)
    return self.create(activity: activity)
  end

  def to_param
    key
  end

  def last_page
    return self.page || self.activity.pages.first
  end

  def increment_run_count!
    self.run_count ||= 0
    increment!(:run_count)
  end

  # Takes an answer or array of answers and generates a portal response JSON string from them.
  def response_for_portal(answer)
    if answer.kind_of?(Array)
      answer.map { |ans| ans.portal_hash }.to_json
    else
      "[#{answer.portal_hash.to_json}]"
    end
  end

  def answers
    open_response_answers + multiple_choice_answers + image_question_answers
  end

  def answers_hash
    answers.map {|a| a.portal_hash}
  end

  def all_responses_for_portal
    answers_hash.to_json
  end

  def oauth_token
    return user.authentication_token if user
    # TODO: throw "no oauth_token for runs without users"
  end

  def bearer_token
    'Bearer %s' % oauth_token
  end

  # TODO: Alias to all_responses_for_portal
  def responses
    {
      'multiple_choice_answers' => self.multiple_choice_answers,
      'open_response_answers' => self.open_response_answers,
      'image_question_answers' => self.image_question_answers
    }
  end

  # return true if we saved.
  def send_to_portal(answers)
    return false if remote_endpoint.nil? || remote_endpoint.blank?
    payload = response_for_portal(answers)
    return false if payload.nil? || payload.blank?
    response = HTTParty.post(
      remote_endpoint, {
        :body => payload,
        :headers => {
          "Authorization" => bearer_token,
          "Content-Type" => 'application/json'
        }
      }
    )
    # TODO: better error detection?
    response.code == 200
  end

  def dirty_answers
    # TODO: Return an array of answers which have a dirty bit set
    return []
  end

  def submit_dirty_answers
    # Find array of dirty answers and send them to the portal
    da = dirty_answers
    if send_to_portal da
      set_answers_clean da # We're only cleaning the same set we sent to the portal
      return true
    else
      return false
    end
  end

  def set_answers_clean(answers)
    # Takes an array of answers and sets their is_dirty bits to clean
    answers.each do |answer|
      answer.is_dirty = false
      answer.save
    end
  end

  def dirty?
    is_dirty
  end

  def set_dirty
    is_dirty = true
    self.save
    # TODO: enqueue
  end

  def set_clean
    is_dirty = false
    self.save
  end

  def update_portal
    if dirty?
      unless submit_dirty_answers && dirty_answers.empty?
        # TODO: If the portal update didn't succeed or there are new dirty answers, requeue
      end
    end
  end
end
