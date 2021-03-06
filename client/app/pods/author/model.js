/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import Ember from 'ember';
import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/pods/nested-question-owner/model';

const { attr, belongsTo } = DS;
const {
  computed,
  computed: { alias },
  isEqual
} = Ember;

export const contributionIdents = [
  'author--contributions--conceptualization',
  'author--contributions--investigation',
  'author--contributions--visualization',
  'author--contributions--methodology',
  'author--contributions--resources',
  'author--contributions--supervision',
  'author--contributions--software',
  'author--contributions--data-curation',
  'author--contributions--project-administration',
  'author--contributions--validation',
  'author--contributions--writing-original-draft',
  'author--contributions--writing-review-and-editing',
  'author--contributions--funding-acquisition',
  'author--contributions--formal-analysis',
];

const validations = {
  firstName: ['presence'],
  lastName: ['presence'],
  authorInitial: ['presence'],
  email: ['presence', 'email'],
  affiliation: ['presence'],
  government: [{
    type: 'presence',
    message: 'A selection must be made',
    validation() {
      const answer = this.get('object') // <- author
                         .answerForQuestion('author--government-employee')
                         .get('value');

      return answer === true || answer === false;
    }
  }],
  orcidIdentifier: [{
    type: 'presence',
    message() {
      const currentUser = this.get('object.currentUser');
      const author = this.get('object.user.content'); // <- promise
      const same = 'This field is required';
      const not  = 'This author needs to provide an ORCID ID before this card can be completed. Please contact the author.';
      return isEqual(currentUser, author) ? same : not;
    },
    skipCheck() {
      if(!window.RailsEnv.orcidConnectEnabled) { return true; }

      const author = this.get('object.user.content'); // <- Promise
      const paperCreator = this.get('object.paper.creator');
      const authorIsNotPaperCreator = !isEqual(author, paperCreator);
      if(authorIsNotPaperCreator) { return true; }
    }
  }],
  contributions: [{
    type: 'presence',
    message: 'One must be selected',
    validation() {
      // NOTE: the validations for contributions is the same as in group-author.js. If you make changes
      // here please also check to see if changes need to be made there.
      const author = this.get('object');
      return _.some(contributionIdents, (ident) => {
        let answer = author.answerForQuestion(ident);
        Ember.assert(`Tried to find an answer for question with ident, ${ident}, but none was found`, answer);
        return answer.get('value');
      });
    }
  }]
};

export default NestedQuestionOwner.extend({
  paper: belongsTo('paper', { async: false }),
  user: belongsTo('user'),
  coAuthorStateModifiedBy: belongsTo('user'),

  orcidAccount: alias('user.orcidAccount'),
  orcidIdentifier: alias('user.orcidAccount.identifier'),
  confirmedAsCoAuthor: Ember.computed.equal('coAuthorState', 'confirmed'),
  refutedAsCoAuthor: Ember.computed.equal('coAuthorState', 'refuted'),
  authorInitial: attr('string'),
  firstName: attr('string'),
  middleInitial: attr('string'),
  lastName: attr('string'),
  email: attr('string'),
  title: attr('string'),
  department: attr('string'),
  coAuthorState: attr('string'),
  coAuthorStateModifiedAt: attr('date'),
  coAuthorConfirmed: computed.equal('coAuthorState', 'confirmed'),

  currentAddressStreet: attr('string'),
  currentAddressStreet2: attr('string'),
  currentAddressCity: attr('string'),
  currentAddressState: attr('string'),
  currentAddressCountry: attr('string'),
  currentAddressPostal: attr('string'),

  affiliation: attr('string'),
  ringgoldId: attr('string'),

  secondaryAffiliation: attr('string'),
  secondaryRinggoldId: attr('string'),

  position: attr('number'),
  corresponding: attr('boolean'),
  deceased: attr('boolean'),

  validations: validations,

  displayName: computed('firstName', 'middleInitial', 'lastName', function() {
    return [
      this.get('firstName'),
      this.get('middleInitial'),
      this.get('lastName')
    ].compact().join(' ');
  }),

  affiliations: Ember.computed('affiliation', 'secondaryAffiliation', function() {
    let affiliations = [this.get('affiliation'), this.get('secondaryAffiliation')];
    // Filtering null values. compact filters for null values if no predicate is given.
    // Return values comma separated in string
    return affiliations.compact().join(', ');
  }),

  fullNameWithAffiliations: Ember.computed('displayName', 'affiliation', 'affiliations', function() {
    if (this.get('affiliation')) {
      return [this.get('displayName'), this.get('affiliations')].compact().join(', ');
    } else {
      return this.get('displayName');
    }
  })
});
