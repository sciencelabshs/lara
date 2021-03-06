class ArgumentationBlockController
  QUESTION_SEL = '.question'
  QUESTION_FROMS_SEL = QUESTION_SEL + ' form'
  SUBMIT_BTN_SEL = '.ab-submit'
  FEEDBACK_SEL = '.ab-feedback'
  FEEDBACK_ID_SEL = '#feedback_on_'
  FEEDBACK_TEXT_SEL = '.ab-robot-feedback-text'
  DIRTY_MSG_SEL = '.ab-dirty'
  ERROR_MSG_SEL = '.ab-error'
  FEEDBACK_HEADER_SEL = '.ab-feedback-header'
  SUBMISSION_COUNT_SEL = '.ab-submission-count'
  SUBMIT_BTN_PROMPT = '.ab-submit-prompt'
  MAX_ERROR_RETRIES = 3
  MAX_STUDENT_SUBMISSIONS = 4

  constructor: (argBlockElement) ->
    @student_submission_attempts = 0
    @$element = $(argBlockElement)
    @$submitBtn = @$element.find(SUBMIT_BTN_SEL)
    @$submitPrompt = @$element.find(SUBMIT_BTN_PROMPT)
    @$submissionCount = @$element.find(SUBMISSION_COUNT_SEL)
    @submissionCount = @$submissionCount.data('submission-count') || 0
    @question = {}
    for q in @$element.find(QUESTION_FROMS_SEL)
      $feedbackEl = $(q).closest(QUESTION_SEL).find(FEEDBACK_SEL)
      isFeedbackDirty = $feedbackEl.data('dirty')
      error = $feedbackEl.data('error')
      @question[@formIDtoAnswerID(q.id)] = {
        # It will be updated by answer_for or no_answer_for event handler.
        answered: false,
        dirty: isFeedbackDirty,
        error: error,
        # 'dirty-data' ensures that question will be always considered as dirty unless it's submitted.
        data: if isFeedbackDirty then 'dirty-data' else $(q).serialize(),
        formElement: q,
        dirtyMsgElement: $feedbackEl.find(DIRTY_MSG_SEL)[0],
        errorMsgElement: $feedbackEl.find(ERROR_MSG_SEL)[0]
      }
    @registerListeners()
    if(@$submitBtn[0].value != t('ARG_BLOCK.SUBMIT'))
      @updateSubmitBtnText()

  registerListeners: ->
    # 'answer_for' and 'no_answer_for' events are defined in save-on-change.
    $(document).on 'answer_for', (e, opt) =>
      @updateQuestion(opt.source, true)
      @updateView()
    $(document).on 'no_answer_for', (e, opt) =>
      @updateQuestion(opt.source, false)
      @updateView()

    @$submitBtn.on 'click', (e) =>
      @submitButtonClicked(e)

  updateQuestion: (id, answered) ->
    q = @question[@formIDtoAnswerID(id)]
    # Undefined means that this question isn't part of the argumentation block.
    return unless q
    q.answered = answered
    q.dirty = q.data != $(q.formElement).serialize()

  submitButtonClicked: (e) ->
    return unless @studentCanSubmit()
    unless @allQuestionAnswered()
      return modalDialog(false, t('ARG_BLOCK.PLEASE_ANSWER'))
    if !@anyQuestionDirty() && !@anyError()
      return modalDialog(false, t('ARG_BLOCK.ANSWERS_NOT_CHANGED'))


    @$submitBtn.prop('disabled', true)
    return if (@student_submission_attempts > MAX_STUDENT_SUBMISSIONS)
    @showWaiting()
    @service_attempts = 0

    @issueRequest()

    @$element.find('.did_try_to_navigate').removeClass('did_try_to_navigate')
    e.preventDefault()
    e.stopPropagation()

  issueRequest: ->
    @service_attempts += 1
    tryAgain = =>
      setTimeout(=>
        @issueRequest()
      , @service_attempts * 1000)

    $.ajax(
      type: 'POST',
      url: @$submitBtn.data('href'),
      accepts: 'application/json',
      success: (data) =>
        for id, q of @question
          q.dirty = false # just updated
          q.error = data.feedback_items[id].error
          q.data = $(q).serialize()
        # Try again in case of some errors.
        return tryAgain() if @anyError() && @service_attempts < MAX_ERROR_RETRIES

        if @anyError()
          # If we are here, it means that service_attempts >= MAX_ERROR_RETRIES. Can't do anything now, just display an error.
          alert(t('ARG_BLOCK.SUBMIT_ERROR'))
        else
          @student_submission_attempts = @student_submission_attempts + 1
          LoggerUtils.craterResponseLogging(data)

        @submissionCount += 1
        @updateSubmitBtnText()
        @updateView(data.feedback_items)
        @scrollToHeader()
        LoggerUtils.submitArgblockLogging(@$submitBtn.data('page_id'))
        @hideWaiting()
        @$submitBtn.prop('disabled', false)
      error: =>
        return tryAgain() if @service_attempts < MAX_ERROR_RETRIES
        alert(t('ARG_BLOCK.SUBMIT_ERROR'))
        # Make sure that user can proceed anyway!
        @enableForwardNavigation()
        @hideWaiting()
        @$submitBtn.prop('disabled', false)
    )

  updateView: (feedbackData, submissionCount) ->
    if feedbackData
      @updateFeedback(feedbackData)
    @updateSubmissionCount()
    @updateSubmitBtn()
    @updateDirtyQuestionMsgs()
    @updateErrorMsgs()
    @updateForwardNavigationBlocking()

  updateSubmissionCount: ->
    @$submissionCount.text(@submissionCount)

  studentCanSubmit: ->
    @student_submission_attempts < MAX_STUDENT_SUBMISSIONS

  updateSubmitBtn: ->
    if @allQuestionAnswered() && (@anyQuestionDirty() || @anyError())
      if @studentCanSubmit()
        @$submitBtn.removeClass('disabled')
        @hideSubmitPrompt()
    else
      @$submitBtn.addClass('disabled')
      @showSubmitPrompt()

  updateSubmitBtnText: ->
    tries_left = MAX_STUDENT_SUBMISSIONS - @student_submission_attempts
    try_or_tries = if (tries_left == 1) then "try" else "tries"
    @$submitBtn[0].value = "Resubmit (#{tries_left} #{try_or_tries} left)"

  showSubmitPrompt: ->
    @$submitPrompt.show()
    unless @studentCanSubmit()
      @$submitPrompt.html( t('ARG_BLOCK.MAX_SUMISSIONS_REACHED') )
      return
    unless @allQuestionAnswered()
      @$submitPrompt.html( t('ARG_BLOCK.PLEASE_ANSWER') )
      return
    unless @anyQuestionDirty()
      @$submitPrompt.html( t('ARG_BLOCK.RESUBMIT_OR_MOVE'))

  hideSubmitPrompt: ->
    @$submitPrompt.css('display', 'none')

  showWaiting: ->
    startWaiting 'Please wait while we analyze your responses...','#loading-container'
    $('#modal-container').show()
    $('#loading-container').css('top', $(window).scrollTop() + 200).show()

  hideWaiting: ->
    stopWaiting('#loading-container')
    $('#modal-container').hide()

  updateDirtyQuestionMsgs: ->
    for id, q of @question
      unless @studentCanSubmit()
        $(q.dirtyMsgElement).html(t('ARG_BLOCK.RESUBMIT_ANSWER_LIMIT_REACHED'))
      if q.dirty
        $(q.dirtyMsgElement).slideDown()
      else
        $(q.dirtyMsgElement).slideUp()

  updateErrorMsgs: ->
    for id, q of @question
      if q.error
        $(q.errorMsgElement).slideDown()
      else
        $(q.errorMsgElement).slideUp()

  updateForwardNavigationBlocking: ->
    if @allQuestionAnswered() && (@noDirtyQuestions() || !@studentCanSubmit() )
      @enableForwardNavigation()
    else
      @disableForwardNavigation()

  scrollToHeader: ->
    $('html, body').animate({
      scrollTop: @$element.offset().top - 10
    }, 400)

  enableForwardNavigation: ->
    $(document).trigger('enable_forward_navigation', {source: 'arg-block'})

  disableForwardNavigation: ->
    $(document).trigger('prevent_forward_navigation', {source: 'arg-block', message: t('PLEASE_SUBMIT')})

  updateFeedback: (feedbackData) ->
    anyFeedbackVisible = false
    for id, feedbackItem of feedbackData
      feedbackItem ||= {score: -1, text: ""}
      $feedback = @$element.find(FEEDBACK_ID_SEL + id)
      # Set feedback text.
      $feedback.find(FEEDBACK_TEXT_SEL).html(feedbackItem.text)
      $feedbackScore = $feedback.find(".ab-robot-scale")
      # Clear old score.
      $feedbackScore.removeClass (idx, oldClasses) ->
        (oldClasses.match(/(^|\s)score-\S+/g) || []).join(' ') # matches all score-<val> classes
      # Clear old max-score.
      $feedbackScore.removeClass (idx, oldClasses) ->
        (oldClasses.match(/(^|\s)max-score-\S+/g) || []).join(' ') # matches all max-score-<val> classes
      # Set new score & max-score
      maxScore = feedbackItem.max_score || 6
      $feedbackScore.addClass("max-score-#{maxScore}")
      if feedbackItem.score? && feedbackItem.score >= 0 && feedbackItem.score <= maxScore
        $feedbackScore.addClass("score-#{feedbackItem.score}")
      else
        $feedbackScore.addClass("score--error")
      # Hide feedback if there is no text.
      if feedbackItem.text
        $feedback.slideDown() # show
        anyFeedbackVisible = true
      else
        $feedback.slideUp() # hide

    if anyFeedbackVisible
      @$element.find(FEEDBACK_HEADER_SEL).slideDown()
    else
      @$element.find(FEEDBACK_HEADER_SEL).slideUp()

  allQuestionAnswered: ->
    for id, q of @question
      return false unless q.answered
    true

  anyQuestionDirty: ->
    for id, q of @question
      return true if q.dirty
    false

  anyError: ->
    for id, q of @question
      return true if q.error
    false

  noDirtyQuestions: ->
    !@anyQuestionDirty()

  formIDtoAnswerID: (htmlId) ->
    # E.g. change "edit_embeddable_open_response_answer_240" to "open_response_answer_240"
    htmlId.replace('edit_embeddable_', '')

$(document).ready ->
  $('.arg-block').each ->
    new ArgumentationBlockController(this)
