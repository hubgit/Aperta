import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import Ember from 'ember';
import testQAIdent from 'tahi/tests/helpers/test-mixins/qa-ident';

moduleForComponent(
  'card-content/date-picker',
  'Integration | Component | card content | date picker',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      this.set('actionStub', function() {});
      this.set('content', Ember.Object.create({ ident: 'test' }));
      this.set('answer', Ember.Object.create({ value: null }));
    }
  }
);

let template = hbs`{{card-content/date-picker
answer=answer
content=content
valueChanged=(action actionStub)
}}`;

test(`it renders a date picker`, function(assert) {
  this.render(template);
  assert.elementFound('input.datepicker');
});

test('includes the ident in the name', function(assert) {
  this.set('content', Ember.Object.create({ ident: 'test' }));
  this.render(template);
  assert.equal(this.$('input').attr('name'), 'date-picker-test');
});

testQAIdent(template);
