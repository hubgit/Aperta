import Ember from 'ember';
import { task as concurrencyTask } from 'ember-concurrency';

let errorText = 'There was a problem saving your invitation. Please refresh.';

export default Ember.Component.extend({
  linkedInvitations: Ember.computed.filter('invitations.@each.primary', function(inv) {
    return inv.get('alternates.length');
  }),

  invitationErrorMessage: null,

  positionSort: ['position:asc'],
  sortedInvitations: Ember.computed.sort('invitations', 'positionSort'),

  invitationsInFlight: Ember.computed('invitations.@each.isSaving', function() {
    return this.get('invitations').isAny('isSaving');
  }),

  changePosition: concurrencyTask(function * (newPosition, invitation) {
    try {
      return yield invitation.changePosition(newPosition);
    } catch (e) {
      this.set('invitationErrorMessage', errorText);
    }
  }).drop(),

  actions: {
    changePosition(newPosition, invitation) {

      let sorted = this.get('sortedInvitations');

      sorted.removeObject(invitation);
      sorted.insertAt(newPosition - 1, invitation);
      this.get('changePosition').perform(newPosition, invitation);
    },

    displayError() {
      this.set('invitationErrorMessage', errorText);
    }
  }
});
