import Ember from 'ember';
var NestedQuestionComponent;

NestedQuestionComponent = Ember.Component.extend({
  tagName: 'div',
  helpText: null,
  disabled: false,
  noResponseText: "[No response]",
  questionTextClass: "question-text",

  model: (function() {
    let ident = this.get('ident');
    Ember.assert(`Expecting to be given an ident, but wasn't`, ident);

    let task = this.get('task');
    Ember.assert(`Expecting to be given a task, but wasn't`, task);

    let decision = this.get('decision');
    let question;
    if(decision){
      question = task.questionForIdentAndDecision(ident, decision);
    } else {
      question = task.findQuestion(ident);
    }
    Ember.assert(`Expecting to find question matching ident '${ident}' but didn't`, question);

    return question;
  }).property('task', 'ident'),

  answerModel: Ember.computed('model', function(){
    return this.get('targetObject.store').createRecord('nested-question-answer', {
      nestedQuestion: this.get('model'),
      task: this.get('task'),
      value: this.get('model.value')
    });
  }),

  additionalData: Ember.computed.alias('model.additionalData'),

  change: function(){
    Ember.run.debounce(this, this._saveAnswer, this.get('answerModel'), 200);
    return false;
  },

  _saveAnswer: function(answerModel){
    answerModel.save();
  }
});

export default NestedQuestionComponent;
