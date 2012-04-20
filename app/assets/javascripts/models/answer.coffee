class Nomad.Models.Answer extends Backbone.Model

  defaults:
    patient_id: null
    values: {}
    
  validate: (attributes)->
    @attributes.created_at ||= new Date()
    @attributes.updated_at = new Date()
    unless attributes.patient_id
      "cannot have an empty patient id"
