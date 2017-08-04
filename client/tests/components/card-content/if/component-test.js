import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import Ember from 'ember';

moduleForComponent(
  'card-content/if',
  'Integration | Component | card content | if then else',
  {
    integration: true,
    beforeEach: function() {
      manualSetup(this.container);
    }
  }
);

let trueTemplate = hbs`
{{card-content/if
  condition=true
  class="true-test"
  owner="this can be anything"
  disabled=disabled
  tagName="div"
  content=content}}`;

let falseTemplate = hbs`
{{card-content/if
  condition=false
  class="false-test"
  owner="this can be anything"
  disabled=disabled
  tagName="div"
  content=content}}`;

let fakeTextContent = Ember.Object.extend({
  contentType: 'text',
  text: 'Child 1' ,
  answerForOwner() {
    return {value: 'foo'};
  }
});

test(
  `when disabled, it marks its children as disabled`,
  function(assert) {
    let content = fakeTextContent.create({
      children: [
        FactoryGuy.make('card-content', 'short-input', { text: 'Child 1' }),
        FactoryGuy.make('card-content', 'short-input', { text: 'Child 2' }),
      ]
    });

    this.set('content', content);
    this.set('disabled', true);
    this.render(trueTemplate);
    assert.elementFound('.card-content-short-input input:disabled', 'found disabled short input');

    this.render(falseTemplate);
    assert.elementFound('.card-content-short-input input:disabled', 'found disabled short input');
  }
);
