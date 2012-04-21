# Extends the base Object with additional helpers that we want all classes in the webapp to have
class Object
  #
  # Converts a hash, like from the Rails params['model_name'], into values for the properties of this class
  #
  # Example:
  #
  # >> form = ProfileFieldForm.new
  # >> form.from_hash({:privacy=>"foo"})
  # >> form.privacy
  # => "foo"
  #
  def from_hash(hash)
    hash.each_key do |key|
      __send__ "#{key}=", hash[key] if self.respond_to? key.to_s+"="
    end
    return self
  end
end
