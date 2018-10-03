module Ratyrate
  module Helpers
    def rating_for(rateable_obj, dimension=nil, options={})

      cached_average = rateable_obj.average dimension
      avg = cached_average ? cached_average.avg : 0

      star         = options[:star]         || 5
      enable_half  = options[:enable_half]  || false
      half_show    = options[:half_show]    || true
      star_path    = options[:star_path]    || ''
      star_on      = options[:star_on]      || image_path('star-on.png')
      star_off     = options[:star_off]     || image_path('star-off.png')
      star_half    = options[:star_half]    || image_path('star-half.png')
      cancel       = options[:cancel]       || false
      cancel_place = options[:cancel_place] || 'left'
      cancel_hint  = options[:cancel_hint]  || 'Cancel current rating!'
      cancel_on    = options[:cancel_on]    || image_path('cancel-on.png')
      cancel_off   = options[:cancel_off]   || image_path('cancel-off.png')
      noRatedMsg   = options[:noRatedMsg]   || 'I\'am readOnly and I haven\'t rated yet!'
      # round        = options[:round]        || { down: .26, full: .6, up: .76 }
      space        = options[:space]        || false
      single       = options[:single]       || false
      target       = options[:target]       || ''
      targetText   = options[:targetText]   || ''
      targetType   = options[:targetType]   || 'hint'
      targetFormat = options[:targetFormat] || '{score}'
      targetScore  = options[:targetScore]  || ''
      readOnly     = options[:readonly]     || false

      disable_after_rate = options[:disable_after_rate] && true
      disable_after_rate = true if disable_after_rate == nil

      unless readOnly
        if disable_after_rate
          readOnly = !(current_user && rateable_obj.can_rate?(current_user, dimension))
        else
          readOnly = !current_user || false
        end
      end

      if options[:imdb_avg] && readOnly
        content_tag :div, '', :style => "background-image:url('#{image_path('mid-star.png')}');width:61px;height:57px;margin-top:10px;" do
            content_tag :p, avg, :style => "position:relative;font-size:.8rem;text-align:center;line-height:60px;"
        end
      else
        content_tag :div, '', "data-dimension" => dimension, :class => "star", "data-rating" => avg,
                    "data-id" => rateable_obj.id, "data-classname" => rateable_obj.class.name == rateable_obj.class.base_class.name ? rateable_obj.class.name : rateable_obj.class.base_class.name,
                    "data-disable-after-rate" => disable_after_rate,
                    "data-readonly" => readOnly,
                    "data-enable-half" => enable_half,
                    "data-half-show" => half_show,
                    "data-star-count" => star,
                    "data-star-path" => star_path,
                    "data-star-on" => star_on,
                    "data-star-off" => star_off,
                    "data-star-half" => star_half,
                    "data-cancel" => cancel,
                    "data-cancel-place" => cancel_place,
                    "data-cancel-hint"  => cancel_hint,
                    "data-cancel-on" => cancel_on,
                    "data-cancel-off" => cancel_off,
                    "data-no-rated-message" => noRatedMsg,
                    # "data-round" => round,
                    "data-space" => space,
                    "data-single" => single,
                    "data-target" => target,
                    "data-target-text" => targetText,
                    "data-target-type" => targetType,
                    "data-target-format" => targetFormat,
                    "data-target-score" => targetScore
      end
    end

    def imdb_style_rating_for(rateable_obj, user, options = {})
      #TODO: add option to change the star icon
      overall_avg = rateable_obj.overall_avg(user)

      content_tag :div, '', :style => "background-image:url('#{image_path('big-star.png')}');width:81px;height:81px;margin-top:10px;" do
          content_tag :p, overall_avg, :style => "position:relative;line-height:85px;text-align:center;"
      end
    end

    def rating_for_user(rateable_obj, rating_user, dimension = nil, options = {})
      @object = rateable_obj
      @user   = rating_user
  	  @rating = Rate.find_by rater: @user, rateable: @object, dimension: dimension
  	  stars = @rating ? @rating.stars : 0

      star         = options[:star]         || 5
      enable_half  = options[:enable_half]  || false
      half_show    = options[:half_show]    || true
      star_path    = options[:star_path]    || ''
      star_on      = options[:star_on]      || image_path('star-on.png')
      star_off     = options[:star_off]     || image_path('star-off.png')
      star_half    = options[:star_half]    || image_path('star-half.png')
      cancel       = options[:cancel]       || false
      cancel_place = options[:cancel_place] || 'left'
      cancel_hint  = options[:cancel_hint]  || 'Cancel current rating!'
      cancel_on    = options[:cancel_on]    || image_path('cancel-on.png')
      cancel_off   = options[:cancel_off]   || image_path('cancel-off.png')
      noRatedMsg   = options[:noRatedMsg]   || 'I\'am readOnly and I haven\'t rated yet!'
      # round        = options[:round]        || { down: .26, full: .6, up: .76 }
      space        = options[:space]        || false
      single       = options[:single]       || false
      target       = options[:target]       || ''
      targetText   = options[:targetText]   || ''
      targetType   = options[:targetType]   || 'hint'
      targetFormat = options[:targetFormat] || '{score}'
      targetScore  = options[:targetScore]  || ''
      readOnly     = options[:readonly]     || false

      disable_after_rate = options[:disable_after_rate] || false

      if disable_after_rate
        readOnly = rating_user.present? ? !rateable_obj.can_rate?(rating_user, dimension) : true
      end

      content_tag :div, '', "data-dimension" => dimension, :class => "star", "data-rating" => stars,
                  "data-id" => rateable_obj.id, "data-classname" => rateable_obj.class.name == rateable_obj.class.base_class.name ? rateable_obj.class.name : rateable_obj.class.base_class.name,
                  "data-disable-after-rate" => disable_after_rate,
                  "data-readonly" => readOnly,
                  "data-enable-half" => enable_half,
                  "data-half-show" => half_show,
                  "data-star-count" => star,
                  "data-star-path" => star_path,
                  "data-star-on" => star_on,
                  "data-star-off" => star_off,
                  "data-star-half" => star_half,
                  "data-cancel" => cancel,
                  "data-cancel-place" => cancel_place,
                  "data-cancel-hint"  => cancel_hint,
                  "data-cancel-on" => cancel_on,
                  "data-cancel-off" => cancel_off,
                  "data-no-rated-message" => noRatedMsg,
                  # "data-round" => round,
                  "data-space" => space,
                  "data-single" => single,
                  "data-target" => target,
                  "data-target-text" => targetText,
                  "data-target-format" => targetFormat,
                  "data-target-score" => targetScore
    end
  end
end

class ActionView::Base
  include Ratyrate::Helpers
end
