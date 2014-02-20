window.Tahi ||= {}

Tahi.init = ->
  Tahi.papers.init()
  Tahi.overlay.init()
  Tahi.overlays.newCard.init()
  Tahi.flowManager.init()

  for form in $("form.js-submit-on-change[data-remote='true']")
    @setupSubmitOnChange $(form), $('select, input[type="radio"], input[type="checkbox"], textarea', form)

  for element in $('[data-overlay-name]')
    Tahi.initOverlay(element)

Tahi.className = (obj) ->
  _.reduce(obj,((memo, val, key) -> if val then "#{memo} #{key}" else memo), "").trim()

Tahi.setupSubmitOnChange = (form, elements, options) ->
  form.on 'ajax:success', options?.success
  elements.off 'change'
  elements.on 'change', (e) ->
    form.trigger 'submit.rails'
