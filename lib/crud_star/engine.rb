require 'crud_star'
require 'crud_star/utility'
require 'rails'
require 'active_record'
require 'action_controller'
require 'will_paginate'

module CrudStar
  class Engine < Rails::Engine
    
    config.application_name = 'CrudStar'
    config.url_path         = 'admin'
    config.theme            = 'green'
    config.navigation       = :dashboard
    
    # Enable the images, stylesheets and JavaScript files to be served in the parent app.
    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
    
    # Load rake tasks
    rake_tasks do
      load 'crud_star/railties/crud_star.rake'
    end
  end
end