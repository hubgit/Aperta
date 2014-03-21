ETahi.PaperTaskRoute = Ember.Route.extend
  model: (params) ->
    paperTasks = _.flatten @modelFor('paper').get('phases').mapProperty('tasks.content')
    paperTasks.findBy('id', params.task_id)

  setupController: (controller, model) ->
    currentPaperId = @controllerFor('paper.manage').get('model.id')
    taskController = @controllerFor model.get('type')
    taskController.set('model', model)
    @set('taskController', taskController)
    if currentPaperId == model.get('phase.paper.id')
      @set('shouldRenderManager', true)
      taskController.set('onClose', 'showManager')

    @set('taskName', model.get('type') || 'AdHocTask')

  renderTemplate: ->
    @render @get('taskName'),
      into: 'application'
      outlet: 'overlay'
      controller: @get('taskController')
    if @get 'shouldRenderManager'
      @render('paper/manage',
        into: 'application')
    else
      @render('overlay_background',
        into: 'application')
