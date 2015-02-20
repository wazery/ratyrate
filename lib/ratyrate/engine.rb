module RatyRate
  class Engine < ::Rails::Engine
    initializer 'ratyrate.load_static_assets' do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/vendor"
    end
  end
end