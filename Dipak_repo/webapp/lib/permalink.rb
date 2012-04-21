#
# From http://www.jvoorhis.com/articles/2005/08/09/howto-enable-permalinking-in-3-steps
#

class ActiveRecord::Base

  def self.uses_permalink( attr )
    self.class_eval <<-EOF, __FILE__, __LINE__
      before_save { |r| r.#{attr}.nil? ? r.permalink = nil : r.permalink = r.#{attr}.to_url } 
    EOF
  end
end

class String

  # From Typo:
  # Converts any string, such as a post title, to its-title-using-dashes
  # All special chars are stripped in the process
  def to_url
    result = self.downcase

    # replace quotes by nothing
    result.gsub!(/['"]/, '')

    # strip all non word chars
    result.gsub!(/\W/, ' ')

    # replace all white space sections with a dash
    result.gsub!(/\ +/, '-')

    # trim dashes
    result.gsub!(/(-)$/, '')
    result.gsub!(/^(-)/, '')

    result
  end
end
