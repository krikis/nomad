unless Array::delete?
  Array::delete = (value) -> 
    deleted = null
    until (index = @indexOf value) == -1
      deleted = @splice index, 1
    deleted
    
unless Array::merge?
  Array::merge = (other) -> 
    Array::push.apply @, other

