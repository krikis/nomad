Array::delete ||= (value) -> 
  deleted = null
  until (index = @indexOf value) == -1
    deleted = @splice index, 1
  deleted
    
Array::merge ||= (other) -> 
  Array::push.apply @, other

