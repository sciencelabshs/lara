{div, label, img} = React.DOM

modulejs.define 'components/itsi_authoring/drawing_response_editor',
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
      'embeddable_drawing_tool[background_image_url]': 'background_image_url'  # TODO: get correct key

    initialEditState: ->
      # TODO: get correct data value
      (@props.data.background_image_url?.length or 0) is 0

    render: ->
      (SectionEditorElement {data: @props.data, title: 'Drawing Response', selected: false, onEdit: @edit},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (label {}, 'Background Image')
            (@text {name: 'embeddable_drawing_tool[background_image_url]'})
          )
        else
          (div {className: 'ia-section-text'},
            if @props.data.background_image_url
              (img {src: @props.data.background_image_url}) # TODO: what should be the fallback image?
            else
              'No background image available. TODO: setup fallback image in asset pipeline.'
          )
      )
