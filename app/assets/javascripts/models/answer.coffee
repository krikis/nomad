class Nomad.Models.Answer extends Backbone.Model

  defaults:
    patient_id: null
    values: {}
    
  validate: (attributes)->
    unless attributes.patient_id
      "cannot have an empty patient id"
