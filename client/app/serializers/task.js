import ApplicationSerializer from 'tahi/serializers/application';

export default ApplicationSerializer.extend({
  serializeIntoHash(data, type, record, options) {
    return data['task'] = this.serialize(record, options);
  },

  primaryTypeName() {
    return 'task';
  }
});
