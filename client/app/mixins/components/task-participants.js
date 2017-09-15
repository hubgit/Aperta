import Ember from 'ember';

export default Ember.Mixin.create({
  store: Ember.inject.service(),
  participations: Ember.computed.alias('task.participations'),

  participants: Ember.computed('participations.@each.user', function() {
    return this.get('participations').mapBy('user');
  }),
  assignedUser: Ember.computed('task.assignedUser', function() {
    let user = this.get('store').peekRecord('user', this.get('task.assignedUserId'));
    return user ? [user] : [];
  }),

  findParticipation(participantId) {
    return this.get('participations').findBy('user.id', '' + participantId);
  },

  createNewParticipation(user, task) {
    return this.get('store').createRecord('participation', {
      user: user,
      task: task
    });
  },

  actions: {
    saveNewParticipant(newParticipant) {
      const user = this.get('store').findOrPush('user', newParticipant);
      if (this.get('participants').includes(user)) { return; }
      this.createNewParticipation(user, this.get('task')).save();
    },

    savedAssignedUser(newUser) {
      const user = this.get('store').findOrPush('user', newUser);
      this.set('task.assignedUserId', user.get('id'));
      this.get('task').save();
      this.set('task.assignedUser', user);
    },

    removeParticipant(participantId) {
      const participant = this.findParticipation(participantId);
      if (!participant) { return; }

      participant.deleteRecord();
      participant.save();
    },

    removeAssignedUser() {
      this.set('task.assignedUserId', null);
      this.get('task').save();
      this.set('task.assignedUser', null);
    }
  }
});
