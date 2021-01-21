class CreateRates < ActiveRecord::Migration<%= migration_version %>

  
  def self.up
    create_table :rates do |t|
      t.belongs_to :rater
      t.belongs_to :rateable, :polymorphic => true
      t.float :stars, :null => false
      t.string :dimension
      t.timestamps
    end

    add_index :rates, :rater_id, name: "rate_rater_id"
    add_index :rates, [:rateable_id, :rateable_type], name: "rate_rateable_id"
  end

  def self.down
    remove_index :rates, [:rateable_id, :rateable_type], name: "rate_rateable_id"
    remove_index :rates, :rater_id, name: "rate_rater_id"

    drop_table :rates
  end

end
