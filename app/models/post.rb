class Post < ActiveRecord::Base

  # before_validation :sanitize_attributes

  attr_protected :id, :remote_id, :remote_version

  validates_uniqueness_of :remote_id

  serialize :remote_version

  private

  def sanitize_attributes
    attributes.each do |key, value|
      if value.is_a? String
        self.send("#{key}=", Sanitize.clean(value))
      end
    end
  end

end
