module Helpers
  def rating_for(rateable_obj, dimension=nil, options={})

    star             = options[:star] || 5
    enable_half      = options[:enable_half] || false
    half_show        = options[:half_show] || false
    star_path        = options[:star_path] || "/assets"
    star_on          = asset_path(options[:star_on] || "star-on.png")
    star_off         = asset_path(options[:star_off] || "star-off.png")
    star_half        = asset_path(options[:star_half] || "star-half.png")
    cancel           = options[:cancel] || false
    cancel_place     = options[:cancel_place] || "left"
    cancel_hint      = options[:cancel_hint] || "Cancel current rating!"
    cancel_on        = asset_path(options[:cancel_on] || "cancel-on.png")
    cancel_off       = asset_path(options[:cancel_off] || "cancel-off.png")
    no_rated_message = options[:no_rated_message] || "I'am readOnly and I haven't rated yet!"
    space            = options[:space] || false
    single           = options[:single] || false
    target           = options[:target] || ''
    target_text      = options[:target_text] || ''
    target_type      = options[:target_type] || 'hint'
    target_format    = options[:target_format] || '{score}'
    target_score     = options[:target_score] || ''
    hints            = options[:hints] || ['bad', 'poor', 'regular', 'good', 'gorgeous']

    disable_after_rate = options[:disable_after_rate] && true
    disable_after_rate = true if disable_after_rate == nil

    readonly = if options.has_key?(:read_only)
                 options[:read_only] == true
               elsif disable_after_rate
                 !(current_user && rateable_obj.can_rate?(current_user, dimension))
               else
                 false
               end

    starts = if options[:stars]
               options[:stars].to_s
             elsif user  = options[:user]
               rating = user.ratings_given.where(rateable: rateable_obj, dimension: dimension).first
               rating ? rating.stars.to_s : 0
             elsif dimension.present?
               cached_average = rateable_obj.average dimension
               cached_average ? cached_average.avg.to_s : 0
             end

    content_tag :div, '', class: 'star', data: {
                        dimension:          dimension,
                        rating:             starts,
                        id:                 rateable_obj.id,
                        classname:          rateable_obj.class.name,
                        disable_after_rate: disable_after_rate,
                        readonly:           readonly,
                        enable_half:        enable_half,
                        half_show:          half_show,
                        star_count:         star,
                        path:               star_path,
                        star_on:            star_on,
                        star_off:           star_off,
                        star_half:          star_half,
                        cancel:             cancel,
                        cancel_place:       cancel_place,
                        cancel_hint:        cancel_hint,
                        cancel_on:          cancel_on,
                        cancel_off:         cancel_off,
                        no_rated_message:   no_rated_message,
                        hints:              hints,
                        space:              space,
                        single:             single,
                        target:             target,
                        target_text:        target_text,
                        target_type:        target_type,
                        target_format:      target_format,
                        target_score:       target_score
                    }
  end

  def average_rating_for(rateable_obj, options = {})
    overall_avg = rateable_obj.overall_average options[:user]

    content_tag :div, '', :style => "background-image:url(/assets/big-star.png);width:81px;height:81px;margin-top:10px;" do
      content_tag :p, overall_avg, :style => "position:relative;line-height:85px;text-align:center;"
    end
  end

  def average_rating_for_user(rateable_obj, user, options = {})
    average_rating_for(rateable_obj, options.merge(user: user))
  end

  def rating_for_user(rateable_obj, rating_user, dimension = nil, options = {})
    rating_for rateable_obj, dimension, options.merge(user: rating_user)
  end
end

class ActionView::Base
  include Helpers
end