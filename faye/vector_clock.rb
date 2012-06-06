class Hash

  # Check whether +self+ supersedes +vector+ in a vector clock way.
  #
  # We say that +self+ supersedes +vector+ when at least one value
  # in +self+ supersedes a value in +vector+ that shares the same key.
  #
  # Note that in this approach we assume that concurrent vector clocks
  # do not exist. This is a reasonable assumption since the server is a
  # 'central point of access' to the persisted vectors and has
  # the opportunity to synchonize all writes. In future work transactions
  # may be used to guarantee synchronicity of vector writes.
  #
  # In future work numerical overflows in clock values should be dealt with 
  # by considering the shortest distance in a circular range. The value
  # ahead on the path with shortest distance supersedes the other values.
  # This approach is justified by the rationale that the path with shortest
  # distance is most likely the correct path from the old clock value
  # to the new clock value. This prevents overflowed clock values to be 
  # treated as old clock values, thus blocking all updates on a once 
  # overflowed object.
  #
  def supersedes?(vector)
    out = false
    self.keys.each do |key|
      if self[key].to_i > vector[key].to_i
        out = true
        break
      end
    end
    out
  end
end
