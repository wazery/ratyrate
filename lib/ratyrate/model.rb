require 'active_support/concern'
module Ratyrate
  extend ActiveSupport::Concern

  def rate(stars, user, dimension=nil)
    dimension = nil if dimension.blank?

    if can_rate? user, dimension
      rates(dimension).create! do |r|
        r.stars = stars
        r.rater = user
      end
    else
      update_current_rate(stars, user, dimension)
    end

    update_rate_average(stars, dimension)
    update_overall_average_rating(stars, user, dimension)
  end

  def overall_average(user=nil)
    if user.present?
      average_rates_for_user(user)
    else
      average_rates
    end
  end

  def update_overall_average_rating(stars, user, dimension)
    # We need user average rating for all dimensions as will as overall rating form all users of all dimensions ( which they have rated )
    user_average = average_rates_for_user(user) || build_average_rates_for_user(rater: user)
    user_average.avg = user.ratings_given.where(rateable: self).average(:stars)
    user_average.qty = user.ratings_given.where(rateable: self).count
    user_average.save validate: false

    overall     = average_rates || build_average_rates
    overall.avg = Rate.where(rateable: self).average(:stars)
    overall.qty = Rate.where(rateable: self).count
    overall.save validate: false
  end

  def update_rate_average(stars, dimension=nil)
    if average(dimension).nil?
      send("create_#{average_assoc_name(dimension)}!", { avg: stars, qty: 1, dimension: dimension })
    else
      a = average(dimension)
      a.qty = rates(dimension).count
      a.avg = rates(dimension).average(:stars)
      a.save!(validate: false)
    end
  end

  def update_current_rate(stars, user, dimension)
    current_rate = rates(dimension).where(rater_id: user.id).take
    current_rate.stars = stars
    current_rate.save!(validate: false)
  end

  def average(dimension=nil)
    send(average_assoc_name(dimension))
  end

  def average_assoc_name(dimension = nil)
    dimension ? "#{dimension}_average" : 'rate_average_without_dimension'
  end

  def can_rate?(user, dimension=nil)
    rates(dimension).where(rater_id: user.id).blank?
  end

  def rates(dimension=nil)
    dimension ? self.send("#{dimension}_rates") : rates_without_dimension
  end

  def raters_for(dimension=nil)
    dimension ? self.send("#{dimension}_raters") : raters_without_dimension
  end

  module ClassMethods
    def ratyrate_rater
      has_many :ratings_given, class_name: "Rate", foreign_key: :rater_id
    end

    def ratyrate_rateable(*dimensions)
      define_method :rating_dimensions do
        dimensions
      end

      has_many :rates_without_dimension, -> { where dimension: nil }, as: :rateable, class_name: "Rate"
      has_many :raters_without_dimension, through: :rates_without_dimension, source: :rater
      has_many :ratings, as: :rateable, class_name: 'Rate', dependent: :destroy
      has_many :raters, -> { select("DISTINCT(rater_id)") }, through: :ratings, source: :rater

      has_one :rate_average_without_dimension, -> { where dimension: nil }, as: :cacheable,
              class_name: "RatingCache", dependent: :destroy
      has_one :average_rates_for_user, -> (user) { where(rater_id: user.id) }, as: :rateable, class_name: 'RatingAverage', dependent: :destroy
      has_one :average_rates, -> { where(rater_id: nil) }, as: :rateable, class_name: 'RatingAverage', dependent: :destroy


      dimensions.each do |dimension|
        has_many "#{dimension}_rates".to_sym, -> { where dimension: dimension.to_s },
                 dependent: :destroy,
                 class_name: "Rate",
                 as: :rateable

        has_many "#{dimension}_raters".to_sym, through: :"#{dimension}_rates", source: :rater

        has_one "#{dimension}_average".to_sym, -> { where dimension: dimension.to_s },
                as: :cacheable, class_name: "RatingCache",
                dependent: :destroy
      end
    end
  end
end

class ActiveRecord::Base
  include Ratyrate
end
