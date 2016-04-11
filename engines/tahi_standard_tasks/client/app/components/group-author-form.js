import Ember from 'ember';
import { contributionIdents } from 'tahi/models/group-author';
import ObjectProxyWithErrors from 'tahi/models/object-proxy-with-validation-errors';

export default Ember.Component.extend({
  classNames: ['author-form', 'group-author-form'],
  author: null,
  authorProxy: null,
  validationErrors: Ember.computed.alias('authorProxy.validationErrors'),

  init() {
    this._super(...arguments);
    this.set('store', this.container.lookup('store:main'));

    if(this.get('isNewAuthor')) {
      this.initNewAuthorQuestions().then(() => {
        this.createNewAuthor();
      });
    }
  },

  nestedQuestionsForNewAuthor: Ember.A(),
  initNewAuthorQuestions(){
    const q = { type: 'GroupAuthor' };
    return this.store.findQuery('nested-question', q).then((nestedQuestions)=> {
      this.set('nestedQuestionsForNewAuthor', nestedQuestions);
    });
  },

  clearNewAuthorAnswers(){
    this.get('nestedQuestionsForNewAuthor').forEach( (nestedQuestion) => {
      nestedQuestion.clearAnswerForOwner(this.get('newAuthor.object'));
    });
  },

  createNewAuthor() {
    const newAuthor = this.store.createRecord('group-author', {
      paper: this.get('task.paper'),
      position: 0,
      nestedQuestions: this.get('nestedQuestionsForNewAuthor')
    });

    this.set('author', newAuthor);

    this.set('authorProxy', ObjectProxyWithErrors.create({
      object: newAuthor,
      validations: newAuthor.validations
    }));
  },

  authorContributionIdents: contributionIdents,

  saveAuthor() {
    this.get('authorProxy').validateAll();
    if(this.get('authorProxy.errorsPresent')) { return; }
    this.get('author').save();
    this.attrs.saveSuccess();
  },

  saveNewAuthor() {
    const author = this.get('author');
    author.save().then(savedAuthor => {
      author.get('nestedQuestionAnswers').toArray().forEach(function(answer){
        const value = answer.get('value');
        if(value || value === false){
          answer.set('owner', savedAuthor);
          answer.save();
        }
      });
    });

    this.attrs.saveSuccess();
  },

  resetAuthor() {
    this.get('author').rollback();
  },

  actions: {
    cancelEdit() {
      this.resetAuthor();
      this.sendAction('hideAuthorForm');
    },

    saveAuthor() {
      if(this.get('isNewAuthor')) {
        this.saveNewAuthor();
      } else {
        this.saveAuthor();
      }
    },

    validateField(key, value) {
      if(this.attrs.validateField) {
        this.attrs.validateField(key, value);
      }
    }
  }
});
