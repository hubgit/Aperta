ETahi.ProfileController = Ember.ObjectController.extend
  newAffiliation: {}
  hideAffiliationForm: true
  errorText: ""

  actions:
    toggleAffiliationForm: ->
      @set('newAffiliation', {})
      @set('hideAffiliationForm', !@hideAffiliationForm)

    removeAffiliation: (affiliation) ->
      if confirm("Are you sure you want to destroy this affiliation?")
        affiliation.destroyRecord()

    createAffiliation: ->
      affiliation = @store.createRecord('affiliation', @newAffiliation)
      affiliation.save().then(
        (affiliation) =>
          affiliation.get('user.affiliations').pushObject(affiliation)
          @set('newAffiliation', {})
          @send('toggleAffiliationForm')
          Ember.run.scheduleOnce 'afterRender', @, ->
            $('.datepicker').datepicker('update')
        ,
        (errorResponse) =>
          errors = for key, value of errorResponse.errors
            messages = for msg in value
              "#{key.dasherize().capitalize().replace("-", " ")} #{value}"
            messages.join(", ")
          Tahi.utils.togglePropertyAfterDelay(@, 'errorText', errors.join(', '), '', 5000)
      )
