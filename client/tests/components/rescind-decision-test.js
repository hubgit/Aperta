import {
  moduleForComponent,
  test
} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';
import customAssertions from '../helpers/custom-assertions';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';
import sinon from 'sinon';


moduleForComponent(
  'rescind-decision',
  'Integration | Component | rescind decision', {
  integration: true,
  beforeEach() {
    initTruthHelpers();
    customAssertions();
    FactoryGuy.setStore(this.container.lookup('store:main'));
  }
});

test('is hidden if there is no decision', function(assert) {
  setup(this, { decision: null });
  assert.elementFound('.rescind-decision.hidden', 'the bar is hidden');
});

test('is hidden if the decision is a draft', function(assert) {
  let decision = FactoryGuy.make('decision', { draft: true });
  setup(this, { decision });
  assert.elementFound('.rescind-decision.hidden', 'the bar is hidden');
});

test('is hidden if the decision is rescinded', function(assert) {
  let decision = FactoryGuy.make('decision', { rescinded: true });
  setup(this, { decision });
  assert.elementFound('.rescind-decision.hidden', 'the bar is hidden');
});

test('button is missing if the decision is not rescindable', function(assert) {
  let decision = FactoryGuy.make('decision', { rescindable: false });
  setup(this, { decision });
  assert.elementNotFound('button.rescind-decision-button', 'the button is hidden');
});

test('button is present if the decision is rescindable', function(assert) {
  let decision = FactoryGuy.make('decision', { completed: true, rescindable: true  });
  setup(this, { decision });
  assert.elementFound('button.rescind-decision-button', 'the button is present');
});

test('rescind link is disabled if not editable', function(assert) {
  let decision = FactoryGuy.make('decision', { completed: true, rescindable : true });
  setup(this, { decision, isEditable: false });
  assert.elementFound('.rescind-decision-button:disabled', 'the button is disabled');
});

test('rescind link, when clicked, calls restless to rescind', function(assert) {
  let decision = FactoryGuy.make('decision', { rescindable: true });
  decision.rescind = sinon.stub()
  decision.rescind.returns({ then: () => {} });
  setup(this, { decision });

  Ember.run(() => {
    // Ask to rescind.
    this.$('.rescind-decision-button').click();

    // Confirm request to rescind
    assert.elementFound(
      '.full-overlay-verification-confirm',
      'Confirm dialog appears');
    this.$('.full-overlay-verification-confirm').click();
  });

  assert.spyCalled(decision.rescind, 'decision was rescinded');
});

function setup(context, {decision, isEditable, mockRestless}) {
  isEditable = (isEditable === false ? false : true); // default true, please

  context.set('decision', decision);
  context.set('isEditable', isEditable);
  context.set('mockRestless', mockRestless);
  let template = hbs`{{rescind-decision decision=decision
                                        isEditable=isEditable
                                        restless=mockRestless}}`;

  context.render(template);
}
