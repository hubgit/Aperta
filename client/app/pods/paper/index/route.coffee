`import Ember from 'ember'`
`import ENV from 'tahi/config/environment'`
`import AuthorizedRoute from 'tahi/routes/authorized'`

PaperIndexRoute = AuthorizedRoute.extend
  viewName: 'paper/index'
  controllerName: 'paper/index'
  templateName: 'paper/index'
  cardOverlayService: Ember.inject.service('card-overlay'),
  restless: Ember.inject.service('restless')
  fromSubmitOverlay: false

  model: ->
    paper = @modelFor('paper')

    taskLoad = new Ember.RSVP.Promise((resolve, reject) ->
      paper.get('tasks').then((tasks) -> resolve(paper)))

    Ember.RSVP.all([taskLoad]).then ->
      paper

  afterModel: (model) ->
    return model.get('tasks')

  setupController: (controller, model) ->
    # paper/index controller is not used.
    # Controller is chosen based on Paper document type
    switch model.get('editorMode')
      when 'latex' then editorLookup = 'paper.index.latex-editor'
      when 'html' then editorLookup = 'paper.index.html-editor'
    @set('editorLookup', editorLookup)

    editorController = @controllerFor(@get('editorLookup'))
    editorController.set('model', model)
    editorController.set('commentLooks', @store.all('commentLook'))

    if @currentUser
      this.get('restless').authorize(
        editorController,
        "/api/papers/#{model.get('id')}/manuscript_manager",
        'canViewManuscriptManager'
      )

  renderTemplate: (paperEditController, model) ->
    @render @get('editorLookup'),
      into: 'application'
      view: @get('editorLookup')
      controller: @get('editorLookup')

  actions:
    viewCard: (task) ->
      @get('cardOverlayService').setProperties({
        previousRouteOptions: ['paper.index', @modelFor('paper')],
        overlayBackground: @get('editorLookup')
      })

      @transitionTo('paper.task', @modelFor('paper'), task.id)

    showConfirmSubmitOverlay: ->
      @controllerFor('overlays/paper-submit').set('model', this.modelFor('paper'))

      @send('openOverlay', {
        template: 'overlays/paper-submit'
        controller: 'overlays/paper-submit'
      })

      @set 'fromSubmitOverlay', true

`export default PaperIndexRoute`
