module ApplicationsExtension
  def reject_all!
    self.each do |a|
      if a.approved? || a.pending?
        a.reject!
      end
    end
  end
end
