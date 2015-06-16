{div, img} = React.DOM

modulejs.define 'components/itsi_authoring/model_editor',
[
  'components/itsi_authoring/section_element_editor_mixin',
  'components/itsi_authoring/section_editor_form',
  'components/itsi_authoring/section_editor_element'
],
(
  SectionElementEditorMixin,
  SectionEditorFormClass,
  SectionEditorElementClass
) ->

  SectionEditorForm = React.createFactory SectionEditorFormClass
  SectionEditorElement = React.createFactory SectionEditorElementClass

  React.createClass

    mixins:
      [SectionElementEditorMixin]

    # maps form names to @props.data keys
    dataMap:
      'mw_interactive[name]': 'name'
      'mw_interactive[url]': 'url'
      'mw_interactive[image_url]': 'image_url'

    initialEditState: ->
      not @props.data.image_url?

    render: ->
      modelOptions = [] # TODO: get options for model - https://learn.staging.concord.org/interactives/export_model_library

      (SectionEditorElement {data: @props.data, title: 'Model', toHide: 'mw_interactive[is_hidden]', onEdit: @edit},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (label {}, 'Model')
            (@select {name: 'mw_interactive[name]', options: modelOptions}) # TODO: update url and image_url when changed
          )
        else
          (div {className: 'ia-section-text'},
            if @props.data.name
              (div {},
                (div {}, @props.data.name)
                (img {src: @props.data.image_url})
              )
            else
              'No model selected'
          )
      )
