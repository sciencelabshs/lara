class VideoInteractive < ActiveRecord::Base
  attr_accessible :poster_url, :caption, :credit

  has_one :interactive_item, :as => :interactive, :dependent => :destroy
  # InteractiveItem is a join model; if this is deleted, that instance should go too

  has_one :interactive_page, :through => :interactive_item

  def to_hash
    {
      poster_url: poster_url,
      caption: caption,
      credit: credit
    }
  end

  def duplicate
    return VideoInteractive.new(self.to_hash)
  end
end
