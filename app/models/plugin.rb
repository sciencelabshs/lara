
class Plugin < ActiveRecord::Base

  attr_accessible :description, :author_data, :approved_script_id, :approved_script, :shared_learner_state_key, :component_label

  belongs_to :approved_script
  belongs_to :plugin_scope, polymorphic: true

  delegate :label, to: :approved_script, allow_nil: true
  delegate :url,   to: :approved_script, allow_nil: true
  delegate :version, to: :approved_script, allow_nil: true

  after_initialize :generate_rare_key

  def generate_rare_key
    self.shared_learner_state_key ||= SecureRandom.uuid()
  end

  def to_hash
    {
      description: description,
      author_data: author_data,
      approved_script_label: approved_script && approved_script.label,
      component_label: component_label
    }
  end

  def export
    self.to_hash
  end

  def self.import(import_hash)
    approved_script_label = import_hash.delete(:approved_script_label)
    if approved_script_label
      script = ApprovedScript.find_by_label(approved_script_label)
      if(script)
        import_hash[:approved_script_id] = script.id
      end
    end
    the_copy = self.new(import_hash)
    return the_copy
  end

  def duplicate
    serialized = self.to_hash
    Plugin.import(serialized)
  end

  def component
    approved_script.component(component_label) if component_label && approved_script
  end

  def name
    if approved_script && component
      "#{approved_script.name}: #{component.name}"
    elsif approved_script
      approved_script.name
    elsif component
      component.name
    else
      nil
    end
  end
end
