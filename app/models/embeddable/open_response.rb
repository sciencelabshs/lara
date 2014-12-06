module Embeddable
  class OpenResponse < ActiveRecord::Base
    attr_accessible :name, :prompt, :is_prediction,
      :give_prediction_feedback, :prediction_feedback

    include Embeddable

    has_many :page_items, :as => :embeddable, :dependent => :destroy
    # PageItem instances are join models, so if the embeddable is gone
    # the join should go too.
    has_many :interactive_pages, :through => :page_items

    has_many :answers,
      :class_name  => 'Embeddable::OpenResponseAnswer',
      :foreign_key => 'open_response_id'

    default_value_for :prompt, "why does ..."

    def to_hash
      {
        name: name,
        prompt: prompt
      }
    end

    def duplicate
      return Embeddable::OpenResponse.new(self.to_hash)
    end

    def self.name_as_param
      :embeddable_open_response
    end

    def self.display_partial
      :open_response
    end

    def self.human_description
      "Multiple choice question"
    end
    
    def export
      return self.as_json(only:[:name,
                                :prompt])
    end
    
    def self.import (import_hash)
      return self.new(import_hash)
    end
  end
end
