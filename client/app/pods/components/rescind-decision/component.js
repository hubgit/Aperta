import Ember from 'ember';

export default Ember.Component.extend({
  decision: null, // pass in an ember-data Decision
  isEditable: true, // pass in false to disable the rescind button

  beforeRescind: null,
  afterRescind: null,

  // States:
  confirmingRescind: false,

  classNames: ['rescind-decision'],
  classNameBindings: ['hidden'],
  notDecision: Ember.computed.not('decision'),
  hidden: Ember.computed.or(
    'notDecision', 'decision.draft', 'decision.rescinded'),

  actions: {
    cancel() {
      this.set('confirmingRescind', false);
    },

    confirmRescind() {
      this.set('confirmingRescind', true);
    },

    rescind() {
      this.set('confirmingRescind', false);

      Ember.tryInvoke(this, 'beforeRescind');
      this.get('decision').rescind().then(() => {
        Ember.tryInvoke(this, 'afterRescind');
      });
    }
  }
});
