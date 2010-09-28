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
    
    # Get a partial name to use. Allows over-riding of default partial by
    # controller.
    #
    def self.get_partial(model, filename)
      Rails.root.join('app', 'views', CrudStar::Engine.config.url_path, model.name.pluralize.parameterize, '_' + filename + '.html.erb').exist? ? File.join(CrudStar::Engine.config.url_path, model.name.pluralize.parameterize, filename) : File.join('crud_star', filename)
    end
    
    
    # Displays field help text for a controller action.
    #
    # Looks for a view partial file in the format of
    # '<controller>/_help_<action>.html.erb'.
    #
    # If the file does not exist, nothing is displayed.
    #
    def self.get_action_help(model, action)
      Rails.root.join('app', 'views', CrudStar::Engine.config.url_path, model.name.pluralize.parameterize, '_help_' + action + '.html.erb').exist? ? File.join(CrudStar::Engine.config.url_path, model.name.pluralize.parameterize, 'help_' + action) : nil
    end
    
    def self.get_field(model, attribute)
      Rails.root.join('app', 'views', CrudStar::Engine.config.url_path, model.name.pluralize.parameterize, '_field_' + attribute.gsub(/\./, '_') + '.html.erb').exist? ? File.join(CrudStar::Engine.config.url_path, model.name.pluralize.parameterize, 'field_' + attribute.gsub(/\./, '_')) : nil
    end
    
    def self.get_filter(model, attribute)
      Rails.root.join('app', 'views', CrudStar::Engine.config.url_path, model.name.pluralize.parameterize, '_filter_' + attribute.gsub(/\./, '_') + '.html.erb').exist? ? File.join(CrudStar::Engine.config.url_path, model.name.pluralize.parameterize, 'filter_' + attribute.gsub(/\./, '_')) : nil
    end
    
    # Displays field help text for a specified attribute.
    #
    # Looks for a view partial file in the format of
    # '<controller>/_help_<attribute>.html.erb'.
    #
    # If the file does not exist, nothing is displayed.
    #
    def self.get_field_help(model, attribute)
      Rails.root.join('app', 'views', CrudStar::Engine.config.url_path, model.name.pluralize.parameterize, '_help_' + attribute.gsub(/\./, '_') + '.html.erb').exist? ? File.join(CrudStar::Engine.config.url_path, model.name.pluralize.parameterize, 'help_' + attribute.gsub(/\./, '_')) : nil
    end
    
    # Determines whether the specified attribute is a required field.
    #
    # Creates and validates an empty new object, and checks if there were any
    # errors on the specified field.
    #
    def self.required_field?(model, attribute)
    
      object = model.new
      object.valid?
    
      error = object.errors[attribute.to_sym].empty? ? false : true
      error ||= object.errors[(attribute + '_id').to_sym].empty? ? false : true
    end
    
    
  
  end
end