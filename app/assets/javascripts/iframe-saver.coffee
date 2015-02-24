# IFrameSaver : Wrapper around IFramePhone to save & Load IFrame data
# into interactive_run_state models in LARA.
class IFrameSaver
  @instances: []  # save-on-change.coffee looks these up.

  # @param iframe         : an iframe to save data from (jQuery)
  # @param $data_div      : an element that includes data-* attributes which describe where we post back to (jQuery)
  # @param $delete_button : an element that is used to trigger data deletion on click (jQuery)
  constructor: ($iframe, $data_div, $delete_button) ->
    @$iframe = $iframe
    @$delete_button = $delete_button
    @put_url = $data_div.data('puturl') # put our data here.
    @get_url = $data_div.data('geturl') # read our data from here.
    @auth_provider = $data_div.data('authprovider') # through which provider did the current user log in
    @user_email = $data_div.data('user-email')
    @logged_in = $data_div.data('loggedin') # true/false - is the current session associated with a user
    @learner_url = null

    @$delete_button.click () =>
      @delete_data()
    @$delete_button.hide()
    @should_show_delete = null
    @saved_state = null

    @save_indicator = SaveIndicator.instance()

    if (@put_url or @get_url)
      IFrameSaver.instances.push @

    model_did_load = () =>
      if @get_url
        @load_interactive()

    phone_answered = () =>
      @iframePhone.addListener 'setLearnerUrl', (learner_url) =>
        @learner_url = learner_url
      @iframePhone.addListener 'interactiveState', (interactive_json) =>
        if @learner_url
          @save_to_server(interactive_json, @learner_url)
        else
          # wait a bit and try again:
          window.setTimeout( =>
            @save_to_server(interactive_json, @learner_url)
          , 500)
      @iframePhone.addListener 'getAuthInfo', =>
        authInfo = {provider: @auth_provider, loggedIn: @logged_in}
        if @user_email?
          authInfo.email = @user_email
        @iframePhone.post('authInfo', authInfo)
      @iframePhone.addListener 'extendedSupport', (opts)=>
        if opts.reset?
          @should_show_delete = opts.reset
          if @saved_state
            if @should_show_delete
              @$delete_button.show()
            else
              @$delete_button.hide()

      if @put_url
        #Save interactive every 5 seconds, on window focus and iframe mouseout just to be safe.
        window.setInterval (=> @save()), 5 * 1000
        $(window).on 'focus', => @save()
        $iframe.on 'mouseout', => @save()

      @iframePhone.post('getExtendedSupport')
      @iframePhone.post('getLearnerUrl')
      # TODO: There used to be a callback for model_did_load
      # hopefully this will work
      model_did_load()

    @iframePhone = new iframePhone.ParentEndpoint($iframe[0], phone_answered)


  @default_success: ->
    console.log "saved"

  error: (msg) ->
    @save_indicator.showSaveFailed(msg)

  save: (success_callback = null) ->
    @success_callback = success_callback

    # will call back into "@save_to_server)
    @iframePhone.post({type: 'getInteractiveState'})

  confirm_delete: (callback) ->
    if (window.confirm("Are you sure you want to restart your work in this model?"))
      callback()

  delete_data: () ->
    @success_callback = () =>
      window.location.reload()
    @confirm_delete () =>
      @learner_url = null
      @save_to_server(null, "")

  save_to_server: (interactive_json, learner_url) ->
    return unless @put_url
    # Do not send the same state to server over and over again.
    return if JSON.stringify(interactive_json) == JSON.stringify(@saved_state)

    runSuccess = =>
      @saved_state = interactive_json
      if @success_callback
        @success_callback()
      else
        @default_success

    if interactive_json is "nochange"
      runSuccess()
      return

    @save_indicator.showSaving()
    data =
      raw_data: JSON.stringify(interactive_json)
      learner_url: learner_url
    $.ajax
      type: "PUT"
      async: false #TODO: For now we can only save this synchronously....
      dataType: 'json'
      url: @put_url
      data: data
      success: (response) =>
        runSuccess()
        @save_indicator.showSaved("Saved Interactive")
      error: (jqxhr, status, error) =>
        @error("couldn't save interactive")

  load_interactive: () ->
    return unless @get_url
    $.ajax
      url: @get_url
      success: (response) =>
        if response['raw_data']
          interactive = JSON.parse(response['raw_data'])
          if interactive
            @saved_state = interactive
            @iframePhone.post({type: 'loadInteractive', content: interactive})
            @$delete_button.show() if @should_show_delete == null or @should_show_delete
      error: (jqxhr, status, error) =>
        @error("couldn't load interactive")

# Export constructor.
window.IFrameSaver = IFrameSaver

$(document).ready ->
  $('.interactive-container.savable').each ->
    $this = $(this)
    $iframe = $this.find('iframe')
    $data = $this.find('.interactive_data_div')
    $delete_button = $this.find('.delete_interactive_data')
    new IFrameSaver($iframe, $data, $delete_button)
