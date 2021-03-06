{div, form, textarea, a} = ReactFactories

modulejs.define 'components/itsi_authoring/text_editor',
[
  'components/common/ajax_form_mixin',
  'components/itsi_authoring/section_editor_form',
  'components/itsi_authoring/tiny_mce_config'
],
(
  AjaxFormMixin,
  SectionEditorFormClass,
  ITSITinyMCEConfig
) ->

  SectionEditorForm = React.createFactory SectionEditorFormClass

  createReactClass

    mixins:
      [AjaxFormMixin]

    # maps form names to @props.data keys
    dataMap:
      'interactive_page[text]': 'text'

    initialEditState: ->
      textLength = @props.data.text?.length or 0
      textLength is 0

    render: ->
      (div {className: 'ia-section-editor-element'},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (@richText {name: 'interactive_page[text]', TinyMCEConfig: ITSITinyMCEConfig})
          )
        else
          (div {className: 'ia-section-text'},
            (a {href: '#', className: 'ia-section-editor-edit', onClick: @edit}, 'edit')
            (div {className: 'ia-section-text-value', dangerouslySetInnerHTML: {__html: @state.values['interactive_page[text]']}})
          )
      )
