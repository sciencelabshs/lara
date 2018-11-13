class LaraSerializationHelper

  def initialize
    @entries = {}
  end

  def export(item)
    results = item.export
    results[:type] = item.class.name
    results[:ref_id] = key(item)
    if item.respond_to?(:interactive) && item.interactive
      results[:interactive_ref_id] = key(item.interactive)
    end
    if item.respond_to?(:embeddable) && item.embeddable
      results[:embeddable_ref_id] = key(item.embeddable)
    end
    if item.respond_to?(:linked_interactive) && item.linked_interactive
      # Why is linked interactive fully serialized while other linked items use reference only?
      # Not sure. It might be related to the fact, that linked interactives can be linked across multiple pages
      # or even activities. However, it doesn't seem it would work if we export and import activity with this
      # interactive missing. I guess it could be double checked and fixed in the future.
      results[:linked_interactive] = self.export(item.linked_interactive)
    end
    results
  end

  def import(item_hash)
    existing_item = lookup_item(item_hash[:ref_id])
    return existing_item if existing_item

    item = item_hash[:type].constantize.import(item_hash.except(:type, :ref_id, :interactive_ref_id, :embeddable_ref_id, :linked_interactive))
    item.save!(validate: false)
    unless item_hash[:ref_id]
      # This is only for backward compatibility when not all the embeddables were defining ref_id in export hash.
      item_hash[:ref_id] = key(item)
    end
    cache_item(item_hash[:ref_id], item)
    item
  end

  def set_references(item_hash)
    item = lookup_item(item_hash[:ref_id])
    if item_hash[:interactive_ref_id] && item.respond_to?(:interactive=)
      item.interactive = lookup_item(item_hash[:interactive_ref_id])
    end
    if item_hash[:embeddable_ref_id] && item.respond_to?(:embeddable=)
      item.embeddable = lookup_item(item_hash[:embeddable_ref_id])
    end
    if item_hash[:linked_interactive] && item.respond_to?(:linked_interactive)
      item.linked_interactive = import(item_hash[:linked_interactive])
    end
    item.save!(validate: false)
    item
  end

  def key(item)
    "#{item.id}-#{item.class.name}"
  end

  private

  def cache_item(ref_id, item)
    @entries[ref_id] = item
  end

  def lookup_item(key_sting)
    @entries[key_sting]
  end
end
