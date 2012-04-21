def help
  Helper.instance
end
 
class Helper
  include Singleton
  # look inside ActionView::Helpers to include any other helpers that you might need
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper
end