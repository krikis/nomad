class Post < ActiveRecord::Base

  # before_validation :sanitize_attributes

  validates_presence_of :title

  private

  def sanitize_attributes
    attributes.each do |key, value|
      if value.is_a? String
        self.send("#{key}=", Sanitize.clean(value))
      end
    end
  end

end
