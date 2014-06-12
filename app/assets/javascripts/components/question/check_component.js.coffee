ETahi.QuestionCheckComponent = Ember.Component.extend
  tagName: 'div'
  layoutName: 'components/question/check_component'
  helpText: null
  multipleAdditionalData: false

  model: (->
    ident = @get('ident')
    throw "you must specify an ident" unless ident

    question = @get('task.questions').findProperty('ident', ident)

    unless question
      question = @get('task.questions').createRecord
        question: @get('question')
        ident: ident
        additionalData: [{}]

    question

  ).property('task', 'ident')

  additionalData: Em.computed.alias('model.additionalData')

  actions:
    additionalDataAction: ()->
      @get('additionalData').pushObject({})

