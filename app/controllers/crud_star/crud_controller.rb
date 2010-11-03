# Filters and methods applied to the controller will affect the entire admin
# control panel.
#
module CrudStar
  class CrudController < CrudStar::AdminController
    
    before_filter :validate_login
    before_filter :validate_access
    
    helper_method :model, :model_name
    hide_action :model, :model_name
  
    # Default 'index' action.
    #
    # Displays a list of entities associated with the child controller's data
    # model.
    #
    # The child controller must define the 'model' method to implement the list.
    #
    # If no list is to be displayed on the index action, you should over-ride this
    # method in the child controller.
    #
    # TODO: conditions (filters)
    #
    # Optional parameters:
    #
    # order   Name of property to sort by. Must match a model attribute.
    # desc    bool - whether to order the list in descending order.
    # page    Page number to view.
    #
    def index(conditions = {}, join_tables = {})
      
        conditions ||= {}
        params[:conditions] ||= {}
      
        # Process the filters input.
        params[:conditions].each do |attribute, value|
        
          item = self.model.new
        
          unless value == 'Please Select'
                
            hierarchy = attribute.split('.')
            count = 0
          
            while (count < hierarchy.size) do
            
              if association = item.class.reflections[hierarchy[count].to_sym]
                item = item.send(hierarchy[count])
                #join_tables << hierarchy[count].to_sym
              else
                column = item.column_for_attribute(hierarchy[count])
              end
            
              count += 1
            end
  
            case column.type
            
              when :boolean
            
                if value == 'true'
                  value = true
                elsif value == 'false'
                  value = false
                else
                  value = nil
                end
            
              when :date
                value = value.empty? ? nil : Date.parse(value)
            
              when :datetime
                value = (value['from'].empty? or value['to'].empty?) ? nil : Date.parse(value['from'])..Date.parse(value['to'])
              
              else
                value = nil if (value.nil? or value.empty? or value.blank?)
            end
          
            attribute = item.class.table_name + '.' + hierarchy.last
            conditions[attribute] = value unless value.nil?
          end
        end
      
        # Determine the ordering of the list.
        if params[:order]
        
          item = self.model.new
        
          order_hierarchy = params[:order].split('.')
        
          for element in order_hierarchy do
          
            if association = item.class.reflections[element.to_sym]
              item = item.send(element)
              #join_tables << element.to_sym
            else
              order = element
            end          
          end
        
          order += ' DESC' if params[:desc]
        end
      
        @list ||= self.model.all(:order => order, :conditions => conditions, :joins => join_tables, :select => 'distinct ' + self.model.table_name + '.*')
      
        unless params[:search].nil? or params[:search].empty?
          search = self.model.search(params[:search])
        
          @list = @list.reject {|item| !search.include?(item) }
        end
      
        if request.format.html? or request.xhr?
          # Grab the paginated list.
          @list = @list.paginate(:page => params[:page], :per_page => 10)
          
          @list_partial = CrudStar::Utility.get_partial(self.model, 'list')
          @list_filter_partial = CrudStar::Utility.get_partial(self.model, 'list_filter')
        end
      
        # Only render the list table partial if this is an AJAX request.
        if request.xhr?
          render(:partial => @list_partial + '.html', :layout => false, :content_type => 'text/html')
          rendered = true
        end
    
      # Render the template outside of above condition in case there's no model.
      if rendered.nil?
      
        respond_to do |format|
        
          @format = request.format
        
          format.html { render(:template => get_template(:format => :html)) }
          format.csv {
            response.headers['Content-disposition'] = 'Attachment; filename="' + self.model.name.underscore + '.csv"' 
            render(:template => get_template(:format => :csv), :layout => false)
          }
        end
      end
    end
  
  
    # The 'show' action.
    #
    # The model must define the 'view_attributes' array which lists the model
    # attributes to display.
    #
    # Required parameters:
    #
    # id    ID of the entity to display
    #
    def show(conditions = nil, join_tables = [])
    
      # Instantiate the session store for database objects.
      session[:crud_star][:objects] ||= {}
      session[:crud_star][:objects][self.model.name.underscore] ||= {}
    
      if @item = self.model.find(params[:id], :conditions => conditions, :include => join_tables)
      
        # If the user has been re-directed to here from a 'cancel' button, delete
        # their changes from the session.
        session[:crud_star][:objects][self.model.name.underscore][@item.id.to_i.to_s] = nil if params[:cancel]
      
        render(:template => get_template)
      end
    end
  
  
    # The 'edit' action.
    #
    # The implementing controller must define the 'edit_attributes' array which
    # lists the model attributes to display in the form.
    #
    # Required parameters:
    #
    # id    ID of the entity to edit
    #
    def edit
    
      # Instantiate the session store for database objects.
      session[:crud_star][:objects] ||= {}
      session[:crud_star][:objects][self.model.name.underscore] ||= {}
    
      # Convert to integer and then string. This is so that the add_associated
      # action will work with both new and saved objects.
      @item_id = params[:id].to_i.to_s
    
      # Store a current copy of the object in the session, so that any
      # associations which are added can be done so without saving immediately. Do
      # not overwrite if it already exists (necessary so non-Ajax requests don't
      # overwrite changes.
      if @item = session[:crud_star][:objects][self.model.name.underscore][@item_id] ||= self.model.find(@item_id)
        render(:template => get_template)
      end
    end
  
  
    # TODO: objects not being removed from session after update!?
    # TODO: Replace use of eval() as security risk
    #
    def update
    
      flash[:errors] = []
    
      # Convert to integer and then string, to remove alphabetic characters from
      # ID. This is so that we can get the object from the session.
      id = params[:id].to_i.to_s
    
      if @item = session[:crud_star][:objects][self.model.name.underscore][id]
      
        params[self.model.name.underscore].each do |name, value|
        
          # Dangerous as taken from user input - find another way!
          eval('@item.' + name + ' = value')
        end
      
        if @item.valid?
        
          if @item.save
            session[:crud_star][:objects][self.model.name.underscore][id] = nil
          
            flash[:updated] = true
            redirect_to(send(CrudStar::Utility.path_for_resource(self.model), @item))
          else
            flash[:errors] = flash[:errors] | @item.errors.full_messages
            redirect_to(send('edit_' + CrudStar::Utility.path_for_resource(self.model), @item))
          end
        
        else
          render(:template => get_template(:filename => :edit))
        end
      end
    end
  
  
    def new
    
      @item_id = params[:id] ||= rand(9999).to_s
    
      # Instantiate the session store for database objects.
      session[:crud_star][:objects] ||= {}
      session[:crud_star][:objects][self.model.name.underscore] ||= {}    
    
      # Store a current copy of the object in the session, so that any
      # associations which are added can be done so without saving immediately. Do
      # not overwrite if it already exists (necessary so non-Ajax requests don't
      # overwrite changes.
      @item = session[:crud_star][:objects][self.model.name.underscore][@item_id] ||= self.model.new
    
      render(:template => get_template)
    end
  
  
    def create
    
      @item_id = params[:id]
    
      if @item = session[:crud_star][:objects][self.model.name.underscore][params[:id]]
      
        params[self.model.name.underscore].each do |name, value|
          @item[name] = value
        end
      
        if @item.valid?
        
          @item.save
        
          session[:crud_star][:objects][self.model.name.underscore][params[:id]] = nil
        
          flash[:created] = true
          redirect_to(self.send(CrudStar::Utility.path_for_resource(self.model), @item))
        else
          render(:template => get_template(:filename => :new))
        end
      end
    end
  
  
    # The 'destroy' action.
    #
    # Deletes an entity and any associations.
    #
    # The :dependent key must be properly configured in all model associations to
    # ensure that associated records are deleted as necessary.
    #
    # Required parameters:
    #
    # id    ID of the entity to delete
    #
    def destroy
    
      flash[:errors] = []
    
      if @item = self.model.find(params[:id].to_i)
        
        if @item.destroy.destroyed?
          flash[:deleted] = true
          redirect_to(self.send(CrudStar::Utility.path_for_resources(self.model)))
        else
          flash[:errors] = flash[:errors] | @item.errors.full_messages
          redirect_to(self.send(CrudStar::Utility.path_for_resource(self.model), @item))
        end
      else
        redirect_to(CrudStar::Utility.path_for_resources(self.model))
      end
    end
  

    # The 'add_associated' action.
    #
    # Adds an associated item to a parent item.
    #
    # The user must first have accessed the new or edit actions, in order for the
    # parent object to be stored in the session. New associated objects are then
    # added to the copy stored in the session and are not saved immediately. The
    # user must commit changes from the form on the edit or new actions.
    #
    # This action is AJAX-compatible; just the list partial will be returned. If
    # the action is not invoked via an AJAX request, the user is re-directed back
    # to the relevant action.
    #
    # TODO: Adding existing objects is saved automatically.
    #
    # Required parameters:
    #
    # id                  The parent item's ID (integer only for saved objects)
    # association_name    The attribute name of the association on the parent
    #                     object.
    #
    def add_associated
    
      # Set this so that the AJAX partial can render the form again properly.
      @item_id = params[:id]
    
      # Check that this is a valid association and get the target item.
      if association = self.model.reflections[params[:association_name].to_sym] and @item = session[:crud_star][:objects][self.model.name.underscore][params[:id].to_i.to_s]
      
        # Determine whether this is a new or existing item.
        if params[params[:association_name].singularize.to_sym][:id]

          unless params[params[:association_name].singularize.to_sym][:id] == 'Please Select'
            
            ass_item = association.klass.find(params[params[:association_name].singularize.to_sym][:id])
            
            unless @item.send(params[:association_name]).include? ass_item
              @item.send(params[:association_name]) << ass_item
            end
          end
        else
        
          # Use the build method so that this new object is not saved automatically.
          # Object will be saved during create or update actions.
          new = @item.send(params[:association_name]).build(params[association.klass.name.underscore.to_sym])
        
          if new.valid?
            params[association.klass.name.underscore.to_sym] = nil
          else
            flash[:object] = new
            @item.send(params[:association_name]).delete(new)
          end
        end
      
        if request.xhr?
          
          partial = CrudStar::Utility.get_partial(association.klass, 'edit_associated')
          
          render(:partial => partial + '.html', :locals => {:association => association, :attribute => params[:association_name]}, :layout => false)
          flash[:object] = nil
        else
        
          # Determine whether to re-direct to the new or edit action.
          url = @item.id.nil? ? self.send(CrudStar::Utility.path_for_new_resource(self.model), :id => @item_id) : self.send(CrudStar::Utility.path_for_edit_resource(self.model), @item, association.klass.name.underscore.to_sym => params[association.klass.name.underscore.to_sym])
        
          redirect_to(url)
        end
      end
    end
  
  
    # TODO: Make a generic view template.
    #
    # TODO: Support more object types in merge comaprison.
    #
    # TODO: Do not delete items immediately. Use
    # @item.send(params[:association_name]).target.delete(item) to remove from
    # item without saving, but then need a way of saving in update action.
    # Probably need to compare session version with database version. Something
    # for the future.
    #
    # Required parameters:
    #
    # id                  The parent item's ID (integer only for saved objects)
    # association_name    The attribute name of the association on the parent
    #                     object.
    #
    def delete_associated
    
      # Set this so that the AJAX partial can render the form again properly.
      @item_id = params[:id]
    
      # Check that this is a valid association and get the target item.
      if association = self.model.reflections[params[:association_name].to_sym] and
        @item = session[:crud_star][:objects][self.model.name.underscore][params[:id]]
      
        # Find the item to delete.
        @item.send(params[:association_name]).each do |item|
        
          # Detect whether the item is the one being deleted. This ASSUMES the
          # input parameters will identify a unique record.
          if item.attributes.merge(params[:item]) {|key, oldval, newval|
          
            if oldval.nil?
              nil
            elsif oldval.class == Fixnum
              newval.to_i
            else
              newval.to_s
            end
          } == item.attributes
          
            # This is the item to be deleted.
            @item.send(params[:association_name]).delete(item)
          end
        
        end
      
        if request.xhr?
          partial = CrudStar::Utility.get_partial(association.klass, 'edit_associated')
          render(:partial => partial + '.html', :locals => {:association => association}, :layout => false)
          flash[:object] = nil
        else
        
          # Determine whether to re-direct to the new or edit action.
          url = @item.id.nil? ? self.send(CrudStar::Utility.path_for_new_resource(self.model), :id => @item_id) : self.send(CrudStar::Utility.path_for_edit_resource(self.model), @item, association.klass.name.underscore.to_sym => params[association.klass.name.underscore.to_sym])
        
          redirect_to(url)
        end
      end
    end
    
    def model
      controller_name.singularize.camelize.constantize
    end
      
    def model_name
      model.model_name.human
    end
  
    # Internal utility methods.
    protected

      # Get a template name to use. Allows over-riding of default template by
      # controller.
      #
      def get_template(options = {})
      
        options[:filename] ||= self.action_name
        options[:format] ||= :html
        
        Rails.root.join('app', 'views', self.controller_path, options[:filename].to_s + '.' + options[:format].to_s + '.erb').exist? ? File.join(self.controller_path, options[:filename].to_s) : File.join('crud_star', options[:filename].to_s)
      end
  end
end
