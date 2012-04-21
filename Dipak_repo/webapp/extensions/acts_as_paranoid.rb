module Caboose #:nodoc:
  module Acts #:nodoc:
    module Paranoid
      module InstanceMethods #:nodoc:
        module ClassMethods
          def undelete_all(conditions = nil)
            self.update_all ["#{self.deleted_attribute} = NULL"], conditions
          end
        end
      end
    end
  end
end
