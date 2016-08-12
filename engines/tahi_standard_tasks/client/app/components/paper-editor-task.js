import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import { eligibleUsersPath } from 'tahi/lib/api-path-helpers';

const { computed } = Ember;

export default TaskComponent.extend({
  restless: Ember.inject.service('restless'),

  autoSuggestSourceUrl: computed('task.id', function(){
    return eligibleUsersPath(this.get('task.id'), 'academic_editors');
  }),

  selectedUser: null,
  composingEmail: false,

  applyTemplateReplacements(str) {
    let editorName = this.get('selectedUser.full_name');
    if (editorName) {
      str = str.replace(/\[EDITOR NAME\]/g, editorName);
    }
    return str.replace(/\[YOUR NAME\]/g, this.get('currentUser.fullName'));
  },

  setLetterTemplate: function() {
    let body, salutation, template;
    template = this.get('task.invitationTemplate');
    if (template.salutation && this.get('selectedUser.full_name')) {
      salutation = this.applyTemplateReplacements(template.salutation) + '\n\n';
    } else {
      salutation = '';
    }

    if (template.body) {
      body = this.applyTemplateReplacements(template.body);
    } else {
      body = '';
    }
    return this.set('invitationBody', '' + salutation + body);
  },

  parseUserSearchResponse(response) {
    return response.users;
  },

  displayUserSelected(user) {
    return user.full_name + ' [' + user.email + ']';
  },

  attachmentsRequest(path, method, s3Url, file) {
    const store = this.get('store');
    const restless = this.get('restless');
    restless.ajaxPromise(method, path, {url: s3Url}).then((response) => {
      response.attachment.filename = file.name;
      store.pushPayload(response);
    });
  },

  actions: {
    cancelAction() {
      this.set('selectedUser', null);
      return this.set('composingEmail', false);
    },

    composeInvite() {
      if (!this.get('selectedUser')) {
        return;
      }
      this.setLetterTemplate();
      this.get('store').createRecord('invitation', {
        task: this.get('task'),
        email: this.get('selectedUser.email'),
        body: this.get('invitationBody'),
        state: 'pending'
      }).save().then((invitation) => {
        this.setProperties({
          invitationToEdit: invitation
        });
      });
    },

    destroyInvitation(invitation) {
      return invitation.rescind();
    },

    didSelectUser(selectedUser) {
      return this.set('selectedUser', selectedUser);
    },

    inviteEditor() {
      if (!this.get('selectedUser')) {
        return;
      }
      this.get('store').createRecord('invitation', {
        task: this.get('task'),
        email: this.get('selectedUser.email'),
        body: this.get('invitationBody')
      }).save().then((invitation) => {
        this.get('task.invitations').addObject(invitation);
        this.set('composingEmail', false);
        this.set('selectedUser', null);
      });
    },

    inputChanged(val) {
      return this.set('selectedUser', {
        email: val
      });
    },

    // These methods are needed by the attachment-manager
    updateAttachment(s3Url, file, attachment) {
      const path = `${this.get('attachmentsPath')}/${attachment.id}/update_attachment`;
      this.attachmentsRequest(path, 'PUT', s3Url, file);
    },

    createAttachment(s3Url, file) {
      this.attachmentsRequest(this.get('attachmentsPath'), 'POST', s3Url, file);
    },

    deleteAttachment(attachment) {
      attachment.destroyRecord();
    },

    updateAttachmentCaption(caption, attachment) {
      attachment.set('caption', caption);
      attachment.save();
    }
  }
});
