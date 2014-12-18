`import Ember from 'ember'`
`import AnimateElement from 'tahi/mixins/routes/animate-element'`
`import RESTless from 'tahi/services/rest-less'`

ApplicationRoute = Ember.Route.extend AnimateElement,
  setupController: (controller, model) ->
    controller.set('model', model)
    if @currentUser
      RESTless.authorize(controller, '/admin/journals/authorization', 'canViewAdminLinks')
      RESTless.authorize(controller, '/user_flows/authorization', 'canViewFlowManagerLink')

  actions:
    willTransition: ->
      @controllerFor('application').send 'hideNavigation'

    loading: (transition, originRoute) ->
      @controllerFor('application').set 'isLoading', true
      @router.one 'didTransition', =>
        @controllerFor('application').set 'isLoading', false

    error: (response, transition, originRoute) ->
      oldState = transition.router.oldState
      transitionMsg = if oldState
        lastRoute = oldState.handlerInfos.get('lastObject.name')
        "Error in transition from #{lastRoute} to #{transition.targetName}"
      else
        "Error in transition into #{transition.targetName}"
      @logError(transitionMsg + "\n" + response.message + "\n" + response.stack + "\n")
      transition.abort()
      @controllerFor('application').set 'isLoading', false

    closeOverlay: ->
      @animateOverlayOut().then =>
        @disconnectOutlet
          outlet: 'overlay'
          parentView: 'application'

    closeAction: ->
      @send('closeOverlay')

    addPaperToEventStream: (paper) ->
      @eventStream.addEventListener(paper.get('eventName'))

    editableDidChange: -> null #noop, this is caught by paper.edit and paper.index

    feedback: ->
      @render('feedback',
        into: 'application'
        outlet: 'overlay')

`export default ApplicationRoute`
