require 'active_support/concern'
module Ratyrate
  extend ActiveSupport::Concern

  def rate(stars, user, dimension=nil, dirichlet_method=false)
    dimension = nil if dimension.blank?

    if can_rate? user, dimension
      rates(dimension).create! do |r|
        r.stars = stars
        r.rater = user
      end
      if dirichlet_method
        update_rate_average_dirichlet(stars, dimension)
      else
        update_rate_average(stars, dimension)
      end
    else
      update_current_rate(stars, user, dimension)
    end
  end

  def update_rate_average_dirichlet(stars, dimension=nil)
    # assumes 5 possible vote categories
    dp = {1 => 1, 2 => 1, 3 => 1, 4 => 1, 5 => 1}
    stars_group = Hash[rates(dimension).group(:stars).count.map{|k,v| [k.to_i,v] }]
    posterior = dp.merge(stars_group){|key, a, b| a + b}
    sum = posterior.map{ |i, v| v }.inject { |a, b| a + b }
    davg = posterior.map{ |i, v| i * v }.inject { |a, b| a + b }.to_f / sum

    if average(dimension).nil?
      send("create_#{average_assoc_name(dimension)}!", { avg: davg, qty: 1, dimension: dimension })
    else
      a = average(dimension)
      a.qty = rates(dimension).count
      a.avg = davg
      a.save!(validate: false)
    end
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

    if rates(dimension).count > 1
      update_rate_average(stars, dimension)
    else # Set the avarage to the exact number of stars
      a = average(dimension)
      a.avg = stars
      a.save!(validate: false)
    end
  end

  def overall_avg(user)
    avg = OverallAverage.where(rateable_id: self.id)
    #FIXME: Fix the bug when the movie has no ratings
    unless avg.empty?
      return avg.take.avg unless avg.take.avg == 0
    else # calculate average, and save it
      dimensions_count = overall_score = 0
      user.ratings_given.select('DISTINCT dimension').each do |d|
        dimensions_count = dimensions_count + 1
        unless average(d.dimension).nil?
          overall_score = overall_score + average(d.dimension).avg
        end
      end
      overall_avg = (overall_score / dimensions_count).to_f.round(1)
      AverageCache.create! do |a|
        a.rater_id = user.id
        a.rateable_id = self.id
        a.rateable_type = self.class.to_s
        a.avg = overall_avg
      end
      overall_avg
    end
  end

  # calculates the movie overall average rating for all users
  def calculate_overall_average
    rating = Rate.where(rateable: self).pluck('stars')
    (rating.reduce(:+).to_f / rating.size).round(1)
  end

  def average(dimension=nil)
    send(average_assoc_name(dimension))
  end

  def average_assoc_name(dimension = nil)
    dimension ? "#{dimension}_average" : 'rate_average_without_dimension'
  end

  def can_rate?(user, dimension=nil)
    rates(dimension).where(rater_id: user.id).size.zero?
  end

  def rates(dimension=nil)
    dimension ? self.send("#{dimension}_rates") : rates_without_dimension
  end

  def raters(dimension=nil)
    dimension ? self.send("#{dimension}_raters") : raters_without_dimension
  end

  module ClassMethods

    def ratyrate_rater
      has_many :ratings_given, class_name: 'Rate', foreign_key: :rater_id
    end

    def ratyrate_rateable(*dimensions)
      has_many :rates_without_dimension, -> { where dimension: nil}, as: :rateable, class_name: 'Rate', dependent: :destroy
      has_many :raters_without_dimension, through: :rates_without_dimension, source: :rater

      has_one :rate_average_without_dimension, -> { where dimension: nil}, as: :cacheable,
              class_name: 'RatingCache', dependent: :destroy

      dimensions.each do |dimension|
        has_many "#{dimension}_rates".to_sym, -> {where dimension: dimension.to_s},
                                              dependent: :destroy,
                                              class_name: 'Rate',
                                              as: :rateable

        has_many "#{dimension}_raters".to_sym, through: :"#{dimension}_rates", source: :rater

        has_one "#{dimension}_average".to_sym, -> { where dimension: dimension.to_s },
                                              as: :cacheable, 
                                              class_name: 'RatingCache',
                                              dependent: :destroy
      end
    end
  end

end

class ActiveRecord::Base
  include Ratyrate
end
