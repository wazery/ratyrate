require 'rails/generators/migration'
require 'rails/generators/active_record'
class RatyrateGenerator < ActiveRecord::Generators::Base
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  desc "copying jquery.raty files to assets directory ..."
  def copying
    copy_file 'jquery.raty.js.erb', 'app/assets/javascripts/jquery.raty.js'
    copy_file 'star-on.png', 'app/assets/images/star-on.png'
    copy_file 'star-off.png', 'app/assets/images/star-off.png'
    copy_file 'star-half.png', 'app/assets/images/star-half.png'
    copy_file 'mid-star.png', 'app/assets/images/mid-star.png'
    copy_file 'big-star.png', 'app/assets/images/big-star.png'
    copy_file 'cancel-on.png', 'app/assets/images/cancel-on.png'
    copy_file 'cancel-off.png', 'app/assets/images/cancel-off.png'
    copy_file 'ratyrate.js.erb', 'app/assets/javascripts/ratyrate.js.erb'
    copy_file 'rater_controller.rb', 'app/controllers/rater_controller.rb'
  end

  desc "model is creating..."
  def create_model
    model_file = File.join('app/models', "#{file_path}.rb")
    raise "User model (#{model_file}) must exits." unless File.exists?(model_file)
    class_collisions 'Rate'
    template 'model.rb', File.join('app/models', "rate.rb")
    template 'cache_model.rb', File.join('app/models', "rating_cache.rb")
    template 'average_cache_model.rb', File.join('app/models', "average_cache.rb")
    template 'overall_average_model.rb', File.join('app/models', "overall_average.rb")
  end

  def add_rate_path_to_route
    route "post '/rate' => 'rater#create', :as => 'rate'"
  end

  desc "cacheable rating average migration is creating ..."
  def create_cacheable_migration
    migration_template "cache_migration.rb", "db/migrate/create_rating_caches.rb", migration_version: migration_version
  end

  desc "migration is creating ..."
  def create_ratyrate_migration
    migration_template "migration.rb", "db/migrate/create_rates.rb", migration_version: migration_version
  end

  desc "average caches migration is creating ..."
  def create_average_caches_migration
    migration_template "average_cache_migration.rb", "db/migrate/create_average_caches.rb", migration_version: migration_version
  end

  desc "overall averages migration is creating ..."
  def create_overall_averages_migration
    migration_template "overall_average_migration.rb", "db/migrate/create_overall_averages.rb", migration_version: migration_version
  end

  def rails5?
    Rails.version.start_with? '5'
  end
  def migration_version
    if rails5?
      "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
    else
      "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      
    end
  end

end
