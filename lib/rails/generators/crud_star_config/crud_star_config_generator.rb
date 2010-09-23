require 'rails/generators'

class CrudStarConfigGenerator < Rails::Generators::Base

  def self.source_root
    File.join(File.dirname(__FILE__), 'templates')
  end

  def copy_initializer_file
    copy_file 'initializer.rb', 'config/initializers/crud_star.rb'
  end

end