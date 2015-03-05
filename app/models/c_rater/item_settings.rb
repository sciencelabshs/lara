class CRater::ItemSettings < ActiveRecord::Base
  belongs_to :provider, polymorphic: true
  belongs_to :score_mapping
  attr_accessible :item_id, :score_mapping_id
  
  def to_hash
    {
      item_id: item_id,
      score_mapping_id: score_mapping_id
    }
  end
  
  def export
    return self.as_json(only:[:item_id,
                              :score_mapping_id])
  end
  
  def duplicate
    return CRater::ItemSettings.new(self.to_hash)
  end
  
  def self.import (import_hash)
    return self.new(import_hash)
  end
end
