module CrudStar
  module ActsAsCrudStar

    module Base
      def self.included(klass)
        klass.extend ClassMethods
      end
      
      module ClassMethods
        
        attr_accessor :crud_star_options
        
        def acts_as_crud_star(options = {})
          
          options[:default_attribute] ||= :id
          options[:resource] ||= CrudStar::Engine.config.url_path + '_' + self.name.pluralize.parameterize
          
          self.crud_star_options = options
          
          include CrudStar::ActsAsCrudStar::Base::InstanceMethods
        end
      end
      
      module InstanceMethods
        
        
                
      end
    end
  end
end

::ActiveRecord::Base.send :include, CrudStar::ActsAsCrudStar::Base
