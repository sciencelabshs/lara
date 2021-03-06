module EmbeddableHelper

  def embeddable_selector
    embeddable_types = Embeddable::Types.map { |k,v| [v, k.to_s] }
    plugin_items = ApprovedScript.authoring_menu_items("embeddable").map { |ami| [ami.name, Embeddable::EmbeddablePlugin.to_s, {"data-approved-script-id" => ami.approved_script_id, "data-component-label" => ami.component_label}] }
    select_tag :embeddable_type, options_for_select(embeddable_types + plugin_items)
  end

  def embeddable_interactives_selector
    select_tag :embeddable_type, options_for_select(Embeddable::InteractiveTypes.map { |k,v| [v, k.to_s] })
  end

  def available_wrapped_embeddable_plugins(embeddable)
    ApprovedScript.authoring_menu_items("embeddable-decoration", embeddable)
  end

  def wrapped_embeddable_selector(embeddable)
    plugin_items = available_wrapped_embeddable_plugins(embeddable).map { |ami| [ami.name, Embeddable::EmbeddablePlugin.to_s, {"data-approved-script-id" => ami.approved_script_id, "data-component-label" => ami.component_label}] }
    if plugin_items.length > 0
      select_tag :embeddable_type, options_for_select(plugin_items), {id: "embeddable_type_#{embeddable.embeddable_dom_id}", class: "wrapped-embeddable-type"}
    else
      nil
    end
  end

  def wrapped_embeddable_plugins(embeddable)
    Embeddable::EmbeddablePlugin.where({embeddable_id: embeddable.id, embeddable_type: embeddable.class.name})
  end
end
