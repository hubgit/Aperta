import Ember from 'ember';

const { get } = Ember;
export default Ember.Component.extend({
  cards: [],
  journal: null,
  newCardOverlayVisible: false,

  routing: Ember.inject.service('-routing'),
  cardsSorting: ['name'],
  sortedCards: Ember.computed.sort('filteredCards', 'cardsSorting'),
  filteredCards: Ember.computed('cards.@each.isNew', function() {
    return this.get('cards')
      .filterBy('isNew', false)
      .reject(card => get(card, 'state') === 'archived');
  }),

  actions: {
    showNewCardOverlay() {
      this.set('newCardOverlayVisible', true);
    },

    hideNewCardOverlay() {
      this.set('newCardOverlayVisible', false);
    },

    editCard(card) {
      this.get('routing').transitionTo('admin.card', [card]);
    }
  }
});
