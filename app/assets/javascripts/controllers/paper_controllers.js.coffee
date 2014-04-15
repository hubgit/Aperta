ETahi.PaperController = Ember.ObjectController.extend
  needs: ['application']

  submissionPhase: ( ->
    @get('phases').findBy('name', 'Submission Data')
  ).property('phases.@each.name')

  downloadLink: ( ->
    "/papers/#{@get('id')}/download"
  ).property()

  authorTasks: Ember.computed.filterBy('submissionPhase.tasks', 'role', 'author')

  authorsTask: (->
    phase = @get('phases').findBy('name', 'Submission Data')
    task = phase.get('tasks').findBy('type', 'AuthorsTask')
  ).property()

  assignedTasks: (->
    assignedTasks = @get('allTasks').filterBy 'assignee', @get('controllers.application.currentUser')
    _.difference assignedTasks, @get('authorTasks')
  ).property('allTasks.@each.assignee')

  reviewerTasks: Ember.computed.filterBy('allTasks', 'role', 'reviewer')

  authorNames: ( ->
    authors = @get('authors').map (author) ->
      [author.first_name, author.last_name].join(' ')
    authors.join(', ') || "Click here to add authors"
  ).property('authors.@each')

# These controllers have to be here for now since the load order
# gets messed up otherwise
ETahi.PaperIndexController = ETahi.PaperController.extend()
ETahi.PaperEditController = ETahi.PaperController.extend()
