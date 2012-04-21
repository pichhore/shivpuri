class EmailJob < Struct.new(:method, :params)
  def perform
    Notifier.send(method, *params)
  end
end
