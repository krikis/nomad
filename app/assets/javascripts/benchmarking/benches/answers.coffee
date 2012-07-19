Benches = @Benches ||= {}

Benches.fixedAnswer = ->
  _.deepClone
    patient_id: '12345678'
    settings:
      flag_1: true
      flag_2: false
    values:
      v_1: 'value_1'
      v_2: 'value_2'
      v_3: 0
      v_4: 1
      v_5: 5
      v_6: Benches.data70KB
    outcome:
      score_1:
        value: 34.5
        clinical: true
      score_2:
        value: 25.3
        clinical: false

Benches.fixedAnswerV1u1 = ->
  _.deepClone
    patient_id: '12345678'
    settings:
      flag_1: false
      flag_2: false
    values:
      v_1: 'value_3'
      v_2: 'value_2'
      v_3: 4
      v_4: 1
      v_5: 5
      v_6: Benches.data70KBv1u1
    outcome:
      score_1:
        value: 21
        clinical: false
      score_2:
        value: 25.3
        clinical: false

Benches.fixedAnswerV1u2 = ->
  _.deepClone
    patient_id: '12345678'
    settings:
      flag_1: false
      flag_2: false
    values:
      v_1: 'value_5'
      v_2: 'value_2'
      v_3: 7
      v_4: 1
      v_5: 5
      v_6: Benches.data70KBv1u2
    outcome:
      score_1:
        value: 23
        clinical: false
      score_2:
        value: 25.3
        clinical: false

Benches.fixedAnswerV1u3 = ->
  _.deepClone
    patient_id: '12345678'
    settings:
      flag_1: false
      flag_2: false
    values:
      v_1: 'value_6'
      v_2: 'value_2'
      v_3: 7
      v_4: 1
      v_5: 5
      v_6: Benches.data70KBv1u3
    outcome:
      score_1:
        value: 23
        clinical: false
      score_2:
        value: 25.3
        clinical: false

Benches.fixedAnswerV2 = ->
  _.deepClone
    patient_id: '12345678'
    settings:
      flag_1: true
      flag_2: true
    values:
      v_1: 'value_1'
      v_2: 'value_4'
      v_3: 0
      v_4: 3
      v_5: 5
      v_6: Benches.data70KBv2
    outcome:
      score_1:
        value: 34.5
        clinical: true
      score_2:
        value: 56
        clinical: true
      