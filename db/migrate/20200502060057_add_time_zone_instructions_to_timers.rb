class AddTimeZoneInstructionsToTimers < ActiveRecord::Migration[5.1]
  def change
    add_column :timers, :time_zone, :string
    add_column :timers, :instruction, :string
  end
end
