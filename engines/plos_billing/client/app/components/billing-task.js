import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';
import DATA from 'tahi/plos-billing-form-data';

const { computed } = Ember;

const pfaCheck = function(task) {
  return task.responseToQuestion('plos_billing--payment_method') !== 'pfa';
};

const PFA_VALIDATION = {
  type: 'number',
  allowBlank: true,
  onlyInteger: true,
  message: `Must be a number and contain no symbols,
            or letters, e.g. $1,000.00 should be written 1000`,
  skipCheck(key) {
    const task      = this.get('task');
    const notPFA    = pfaCheck(task);
    const notActive = !(task.responseToQuestion(key));
    return notPFA || notActive;
  }
};

export default TaskComponent.extend({
  validations: {
    'plos_billing--first_name':        ['presence'],
    'plos_billing--last_name':         ['presence'],
    'plos_billing--department':        ['presence'],
    'plos_billing--affiliation1':      ['presence'],
    'plos_billing--phone_number':      ['presence'],
    'plos_billing--email':             ['presence'],
    'plos_billing--address1':          ['presence'],
    'plos_billing--city':              ['presence'],
    'plos_billing--postal_code':       ['presence'],
    'plos_billing--pfa_question_1b':   [PFA_VALIDATION],
    'plos_billing--pfa_question_2b':   [PFA_VALIDATION],
    'plos_billing--pfa_question_3a':   [PFA_VALIDATION],
    'plos_billing--pfa_question_4a':   [PFA_VALIDATION],
    'plos_billing--pfa_amount_to_pay': [PFA_VALIDATION],
  },

  init() {
    this._super(...arguments);
    this.get('countries').fetch();
  },

  countries: Ember.inject.service(),
  ringgold: [],
  institutionalAccountProgramList: DATA.institutionalAccountProgramList,
  states:    DATA.states,
  pubFee:    DATA.pubFee,
  journals:  DATA.journals,
  responses: DATA.responses,
  groupOneAndTwoCountries: DATA.groupOneAndTwoCountries,

  formattedCountries: computed('countries.data', function() {
    return this.get('countries.data').map(function(c) {
      return { id: c, text: c };
    });
  }),

  journalName: 'PLOS One',
  inviteCode: '',
  endingComments: '',

  feeMessage: computed('journalName', function() {
    return 'The fee for publishing in ' + this.get('journalName') +
      ' is $' + this.get('pubFee');
  }),

  selectedRinggold: null,
  selectedPaymentMethod: computed('model.nestedQuestionAnswers.[]', function(){
    return this.get('task')
               .answerForQuestion('plos_billing--payment_method')
               .get('value');
  }),

  agreeCollections: false,

  affiliation1Question: computed('model.nestedQuestions.[]', function() {
    return this.get('task').findQuestion('plos_billing--affiliation1');
  }),

  affiliation2Question: computed('model.nestedQuestions.[]', function() {
    return this.get('task').findQuestion('plos_billing--affiliation2');
  }),

  // institution-search component expects data to be
  // hash with name property
  affiliation1Proxy: computed('affiliation1Question', function(){
    const question = this.get('affiliation1Question');
    const answer = question.answerForOwner(this.get('task'));
    if(answer.get('wasAnswered')) {
      return { name: answer.get('value') };
    }
  }),

  // institution-search component expects data to be hash
  // with name property
  affiliation2Proxy: computed('affiliation2Question', function(){
    const question = this.get('affiliation2Question');
    const answer = question.answerForOwner(this.get('task'));
    if(answer.get('wasAnswered')) {
      return { name: answer.get('value') };
    }
  }),

  setAffiliationAnswer(index, answerValue) {
    const question = this.get('affiliation' + index + 'Question');
    const answer = question.answerForOwner(this.get('task'));

    if(typeof answerValue === 'string') {
      answer.set('value', answerValue);
    } else if(typeof answerValue === 'object') {
      answer.set('value', answerValue.name);
      answer.set('additionalData', {
        answer: answerValue.name,
        additionalData: answerValue
      });
    }

    answer.save();
  },

  actions: {
    paymentMethodSelected(selection) {
      this.set('selectedPaymentMethod', selection.id);
    },

    affiliation1Selected(answer) {
      this.setAffiliationAnswer('1', answer);

      this.validateQuestion(
        this.get('affiliation1Question.ident'),
        answer
      );
    },

    affiliation2Selected(answer) { this.setAffiliationAnswer('2', answer); }
  }
});
