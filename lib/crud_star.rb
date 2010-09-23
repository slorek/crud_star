module CrudStar
  require 'crud_star/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'crud_star/acts_as_crud_star/base'
end