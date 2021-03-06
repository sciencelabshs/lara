{div, a, h1, label} = ReactFactories

modulejs.define 'components/itsi_authoring/metadata_editor',
[
  'components/common/ajax_form_mixin',
  'components/itsi_authoring/section_editor_form'
],
(
  AjaxFormMixin,
  SectionEditorFormClass
) ->

  SectionEditorForm = React.createFactory SectionEditorFormClass

  createReactClass
    mixins: [AjaxFormMixin]

    updateUrl: ->
      @props.data.update_url

    # maps form names to @props.data keys
    dataMap:
      'lightweight_activity[name]': 'name',
      'lightweight_activity[description]': 'description'

    render: ->
      (div {className: 'ia-section-editor-element ia-metadata'},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (label {}, 'Activity name')
            (@text {name: 'lightweight_activity[name]'})
            (label {}, 'Activity description')
            (@textarea {name: 'lightweight_activity[description]'})
          )
        else
          (div {className: 'ia-section-text'},
            (a {href: '#', className: 'ia-section-editor-edit', onClick: @edit}, 'edit')
            (h1 {}, @state.values['lightweight_activity[name]'])
            (div {className: 'ia-section-text-value'}, @state.values['lightweight_activity[description]'])
          )
      )
