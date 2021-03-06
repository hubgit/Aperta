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
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';


const isAdHocTask = function(kind) {
  const adHocTaskTypes = [
    'AdHocTask',
    'AdHocForAuthorsTask',
    'AdHocForEditorsTask',
    'AdHocForReviewersTask'
  ];
  return adHocTaskTypes.includes(kind);
};

export default Ember.Controller.extend(ValidationErrorsMixin, {
  pendingChanges: false,
  editingName: false,
  positionSort: ['position:asc'],
  journal: Ember.computed.alias('model.journal'),
  phaseTemplates: Ember.computed.alias('model.phaseTemplates'),
  sortedPhaseTemplates: Ember.computed.sort('phaseTemplates', 'positionSort'),
  showSaveButton: Ember.computed.or('pendingChanges', 'editingName'),

  settingsTitle: Ember.computed('taskToConfigure', function() {
    return this.get('taskToConfigure.title') + ': Settings';
  }),

  showCardDeleteOverlay: false,
  taskToDelete: null,

  showSettingsOverlay: false,
  taskToConfigure: null,

  showAdHocTaskOverlay: false,
  adHocTaskToDisplay: null,

  showChooseNewCardOverlay: false,
  addToPhase: null,
  journalTaskTypes: [],
  cards: [],
  journalTaskTypesIsLoading: false,

  saveTemplate(transition){
    this.get('model').save().then(() => {
      this.successfulSave(transition);
    }, (response) => {
      this.displayValidationErrorsFromResponse(response);
    });
  },

  successfulSave(transition){
    this.resetProperties();
    if (transition) {
      this.transitionToRoute(transition);
    }else{
      let defaultRoute = 'admin.mmt.journal.manuscript_manager_template.edit';
      this.transitionToRoute(defaultRoute, this.get('model'));
    }
  },

  updateTaskPositions(itemList) {
    this.beginPropertyChanges();
    itemList.forEach((item, index) => {
      item.set('position', index + 1);
    });
    this.endPropertyChanges();
  },

  resetProperties(){
    this.setProperties({ editingName: false, pendingChanges: false });
  },

  redirectToAdminPage(journal){
    this.transitionToRoute('admin.journals.workflows', journal);
  },

  buildTaskTemplate(title, journalTaskType, card, phaseTemplate) {
    return this.store.createRecord('task-template', {
      title: title,
      journalTaskType: journalTaskType,
      card: card,
      phaseTemplate: phaseTemplate,
      template: []
    });
  },

  actions: {
    toggleResearchArticleReviewerReport(value) {
      this.set('model.usesResearchArticleReviewerReport', value);
      this.get('model').save();
    },

    togglePreprint(value) {
      this.set('model.isPreprintEligible', value);
      this.get('model').save();
    },

    hideAdHocTaskOverlay() {
      this.setProperties({
        showAdHocTaskOverlay: false,
        pendingChanges: true
      });
    },

    showChooseNewCardOverlay(phase) {
      this.setProperties({
        addToPhase: phase,
        journalTaskTypesIsLoading: true
      });

      const journalId = this.get('model.journal.id');
      this.store.findRecord('admin-journal', journalId).then(adminJournal => {
        this.setProperties({
          journalTaskTypes: adminJournal.get('journalTaskTypes'),
          cards: adminJournal.get('cards'),
          journalTaskTypesIsLoading: false
        });
      });

      this.set('showChooseNewCardOverlay', true);
    },

    hideChooseNewCardOverlay() {
      this.set('showChooseNewCardOverlay', false);
    },

    addTaskTemplate(phaseTemplate, selectedCards) {
      if (!selectedCards) { return; }

      let hasAdHocType = false;

      selectedCards.forEach((item) => {
        let newTaskTemplate;

        if(item.constructor.modelName === 'card') {
          // task template from a Card
          newTaskTemplate = this.buildTaskTemplate(item.get('name'), null, item, phaseTemplate);
        } else {
          // task template from a JournalTaskType
          newTaskTemplate = this.buildTaskTemplate(item.get('title'), item, null, phaseTemplate);
        }

        // reposition phases
        this.updateTaskPositions(phaseTemplate.get('taskTemplates'));

        if (isAdHocTask(item.get('kind'))) {
          hasAdHocType = true;
          this.set('adHocTaskToDisplay', newTaskTemplate);
        }
      });

      if (hasAdHocType) {
        this.set('showAdHocTaskOverlay', true);
      }

      this.set('pendingChanges', true);
    },

    showCardDeleteOverlay(task) {
      this.set('taskToDelete', task);
      this.set('showCardDeleteOverlay', true);
    },

    hideCardDeleteOverlay() {
      this.set('showCardDeleteOverlay', false);
    },

    showSettingsOverlay(task) {
      this.set('taskToConfigure', task);
      this.set('showSettingsOverlay', true);
    },

    hideSettingsOverlay() {
      this.set('showSettingsOverlay', false);
    },

    editMmtName(){
      this.clearAllValidationErrors();
      this.setProperties({ editingName: true, pendingChanges: true });
    },

    taskMovedWithinList(item, oldIndex, newIndex, itemList) {
      itemList.removeAt(oldIndex);
      itemList.insertAt(newIndex, item);
      this.updateTaskPositions(itemList);
      this.set('pendingChanges', true);
    },

    taskMovedBetweenList(
      item, oldIndex, newIndex, newList, sourceItems, newItems) {
      sourceItems.removeAt(oldIndex);
      newItems.insertAt(newIndex, item);
      item.set('phaseTemplate', newList);

      this.updateTaskPositions(sourceItems);
      this.updateTaskPositions(newItems);

      this.set('pendingChanges', true);
    },

    startDragging(item, container) {
      item.addClass('card--dragging');
      container.parent().addClass('column-content--dragging');
    },

    stopDragging(item, container) {
      item.removeClass('card--dragging');
      container.parent().removeClass('column-content--dragging');
    },

    addPhase(position){
      this.get('phaseTemplates').forEach(function(phaseTemplate) {
        if (phaseTemplate.get('position') >= position) {
          phaseTemplate.incrementProperty('position');
        }
      });

      this.store.createRecord('phase-template', {
        name: 'New Phase',
        manuscriptManagerTemplate: this.get('model'),
        position: position
      });

      this.set('pendingChanges', true);
    },

    removeRecord(record){
      record.deleteRecord();
      record.unloadRecord();
      this.set('pendingChanges', true);
    },

    rollbackPhase(phase, oldName){
      phase.set('name', oldName);
    },

    savePhase(){
      this.set('pendingChanges', true);
    },

    saveTemplateOnClick(transition){
      this.saveTemplate(transition);
    },

    editTaskTemplate(taskTemplate){
      if (isAdHocTask(taskTemplate.get('kind'))) {
        this.setProperties({
          showAdHocTaskOverlay: true,
          adHocTaskToDisplay: taskTemplate
        });
      }
    },

    cancel(){
      if (this.get('model.isNew')){
        const journal = this.get('journal');
        this.get('model').deleteRecord();
        this.resetProperties();
        this.redirectToAdminPage(journal);
      } else {
        this.store.unloadAll('task-template');
        this.store.unloadAll('phase-template');
        this.get('model').rollbackAttributes();
        this.get('journal').reload().then(() => {
          this.resetProperties();
        });
      }
    }
  }
});
