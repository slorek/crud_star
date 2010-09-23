module CrudStar
  class Utility
  
    def self.path_for_resource(resource)
      ar = [CrudStar::Engine.config.url_path, resource.to_s.singularize.parameterize, 'path'].delete_if {|i| i.nil? or i.to_s.empty?}
      ar.join('_')
    end
    
    def self.path_for_new_resource(resource)
      ar = ['new', CrudStar::Engine.config.url_path, resource.to_s.singularize.parameterize, 'path'].delete_if {|i| i.nil? or i.to_s.empty?}
      ar.join('_')
    end
    
    def self.path_for_edit_resource(resource)
      ar = ['edit', CrudStar::Engine.config.url_path, resource.to_s.singularize.parameterize, 'path'].delete_if {|i| i.nil? or i.to_s.empty?}
      ar.join('_')
    end
    
    def self.path_for_resources(resource)
      ar = [CrudStar::Engine.config.url_path, resource.to_s.pluralize.parameterize, 'path'].delete_if {|i| i.nil? or i.to_s.empty?}
      ar.join('_')
    end
  
  end
end