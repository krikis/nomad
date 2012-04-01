class PostObserver < ActiveRecord::Observer
  include BackboneSync::Rails::Faye::Observer
end
