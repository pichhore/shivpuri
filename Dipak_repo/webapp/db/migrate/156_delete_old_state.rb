class DeleteOldState < ActiveRecord::Migration
  def self.up
    logger = Logger.new("#{RAILS_ROOT}/log/deleted_states.log")
    begin
      states = State.find_by_sql('select * from states where id not in ( select state_id from territories group by state_id)')
      states.each do |state|
        logger.info " state deleted : name = #{state.name} --- code =#{state.state_code} "
        state.destroy
      end
    rescue Exception=>exp
      logger.info " TrustResponderSetup error 1 : (#{exp.class}) #{exp.message.inspect} "
    end
  end

  def self.down
  end
end
