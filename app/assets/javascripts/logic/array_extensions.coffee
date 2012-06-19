unless Array::merge?
  Array::merge = (other) -> 
    Array::push.apply @, other