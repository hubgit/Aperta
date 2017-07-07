import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['card-editor-preview-overlay'],
  renderAdditionalText: Ember.computed('card.content.unsortedChildren.[]', function() {
    let cardContents = this.get('card.content.unsortedChildren.[]');
    return cardContents.any((cardContent) => {
      return cardContent.get('renderAdditionalText');
    });
  }),
});
