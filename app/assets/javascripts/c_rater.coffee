class ArgumentationBlockController
  QUESTION_SEL = '.question'
  QUESTION_FROMS_SEL = '.arg-block ' + QUESTION_SEL + ' form'
  SUBMIT_BTN_SEL = '#ab-submit'
  FEEDBACK_SEL = '.ab-feedback'
  FEEDBACK_ID_SEL = '#feedback_on_answer_'
  FEEDBACK_TEXT_SEL = '.ab-feedback-text'
  DIRTY_MSG_SEL = '.ab-dirty'

  constructor: ->
    @$submitBtn = $(SUBMIT_BTN_SEL)
    @question = {}
    for q in $(QUESTION_FROMS_SEL)
      isFeedbackDirty = $(q).closest(QUESTION_SEL).find(FEEDBACK_SEL).data('dirty')
      @question[q.id] = {
        element: q,
        # It will be updated by answer_for or no_answer_for event handler.
        answered: false,
        dirty: isFeedbackDirty,
        # 'dirty-data' ensures that question will be always considered as dirty unless it's submitted.
        data: if isFeedbackDirty then 'dirty-data' else $(q).serialize(),
        dirtyMsgElement: $(q).closest(QUESTION_SEL).find(FEEDBACK_SEL).find(DIRTY_MSG_SEL)[0]
      }
    @registerListeners()

  registerListeners: ->
    $(document).on 'answer_for', (e, opt) =>
      @updateQuestion(opt.source, true)
      @updateView()
    $(document).on 'no_answer_for', (e, opt) =>
      @updateQuestion(opt.source, false)
      @updateView()

    @$submitBtn.on 'click', (e) =>
      @submitButtonClicked(e)

  updateQuestion: (id, answered) ->
    q = @question[id]
    # Undefined means that this question isn't part of the argumentation block.
    return unless q
    q.answered = answered
    q.dirty = q.data != $(q.element).serialize()

  submitButtonClicked: (e) ->
    unless @allQuestionAnswered()
      return modalDialog(false, 'Please answer all questions in the argumentation block.')
    unless @anyQuestionDirty()
      return modalDialog(false, 'Answers have not been changed.')

    @$submitBtn.prop('disabled', true)
    $.ajax(
      type: "POST",
      url: @$submitBtn.data('href'),
      accepts: 'application/json',
      success: (feedbackData) =>
        for id, q of @question
          q.dirty = false # just updated
          q.data = $(q).serialize()
        @updateView(feedbackData)
      complete: =>
        @$submitBtn.prop('disabled', false)
    )
    e.preventDefault()
    e.stopPropagation()

  updateView: (feedbackData) ->
    @updateSubmitBtn()
    @updateDirtyQuestionMsgs()
    @updateForwardNavigationBlocking()
    if feedbackData
      @updateFeedback(feedbackData)

  updateSubmitBtn: ->
    if @allQuestionAnswered() && @anyQuestionDirty()
      @$submitBtn.removeClass('disabled')
    else
      @$submitBtn.addClass('disabled')

  updateDirtyQuestionMsgs: ->
    for id, q of @question
      if q.dirty
        $(q.dirtyMsgElement).slideDown()
      else
        $(q.dirtyMsgElement).slideUp()

  updateForwardNavigationBlocking: ->
    if @allQuestionAnswered() && @noDirtyQuestions()
      $(document).trigger('enable_forward_navigation', {source: 'arg-block'})
    else
      $(document).trigger('prevent_forward_navigation', {source: 'arg-block'})

  updateFeedback: (data) ->
    for id, feedbackText of data
      $(FEEDBACK_ID_SEL + id).find(FEEDBACK_TEXT_SEL).text(feedbackText)
      if !!feedbackText
        $(FEEDBACK_ID_SEL + id).slideDown()
      else
        $(FEEDBACK_ID_SEL + id).slideUp()

  allQuestionAnswered: ->
    for id, q of @question
      return false unless q.answered
    true

  anyQuestionDirty: ->
    for id, q of @question
      return true if q.dirty
    false

  noDirtyQuestions: ->
    !@anyQuestionDirty()

$(document).ready ->
  new ArgumentationBlockController()
