class RatingAverage < ActiveRecord::Base
  belongs_to :rateable, polymorphic: true
  belongs_to :rater, class_name:  "<%= file_name.classify %>"
end

