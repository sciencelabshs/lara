class Embeddable::ImageQuestion < ActiveRecord::Base
  attr_accessible :name, :prompt, :bg_source

  include Embeddable

  has_many :page_items, :as => :embeddable, :dependent => :destroy
  has_many :interactive_pages, :through => :page_items

  has_many :answers,
    :class_name  => 'Embeddable::ImageQuestionAnswer',
    :foreign_key => 'image_question_id',
    :dependent   => :destroy

  default_value_for :prompt, "why does ..."

  def to_hash
    {
      name: name,
      prompt: prompt,
      bg_source: bg_source
    }
  end

  def duplicate
    return Embeddable::ImageQuestion.new(self.to_hash)
  end

  def is_shutterbug?
    bg_source == 'Shutterbug'
  end

  def is_drawing?
    bg_source == 'Drawing'
  end

  def is_annotation?
    bg_source.match /^http/
  end

  def self.name_as_param
    :embeddable_image_question
  end

  def self.display_partial
    :image_question
  end

  def self.human_description
    "Image question"
  end
end
