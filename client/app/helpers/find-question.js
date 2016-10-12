import Ember from 'ember';

export function findQuestion(params, hash) {
  let [owner, ident] = params;

  let question = owner.get('nestedQuestions').findBy('ident', ident);
  if (hash.answer) {
    return question.answerForOwner(owner);
  } else {
    return question;
  }
}

export default Ember.Helper.helper(findQuestion);
