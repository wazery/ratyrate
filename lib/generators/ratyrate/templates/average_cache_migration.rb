class CreateAverageCaches < ActiveRecord::Migration<%= migration_version %>

  def self.up
    create_table :average_caches do |t|
      t.belongs_to :rater
      t.belongs_to :rateable, :polymorphic => true
      t.float :avg, :null => false
      t.timestamps
    end

    add_index :average_caches, [:rater_id, :rateable_id, :rateable_type]
  end

  def self.down
    drop_table :average_caches
  end

end

