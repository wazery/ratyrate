class CreateRatingAverages < ActiveRecord::Migration

  def change
    create_table :rating_averages do |t|
      t.belongs_to :rateable, polymorphic:  true
      t.float :avg, null:false
      t.belongs_to :rater

      t.timestamps
    end

    add_index :rating_averages, [:rateable_id, :rateable_type]
    add_index :rating_averages, [:rateable_id, :rateable_type, :rater_id]
  end
end

