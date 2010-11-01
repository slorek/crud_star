# Filters and methods applied to the controller will affect the entire admin
# control panel.
#
module CrudStar
  class AdminController < ApplicationController
  
    # Use ActiveRecord as the session store for the admin area so we can store
    # objects which are being edited. The cookie store is limited to 4KB. Change
    # the session key to separate from the main site.
    #session :database_manager => CGI::Session::ActiveRecordStore,
    #        :session_key => 'fairline_rsvp_admin_session_id'
  
    layout 'crud_star'
  
    # Hide these controller methods so they are not as accessible as actions.
    # Cannot set as protected or private due to inheritance and view dependance.
    hide_action ['sidebar_actions', 'permissions']
    
    before_filter :init
  
    def sidebar_actions
      {:admin => {}}
    end
  
  
    def permissions
      {:admin => []}
    end

  
    # Internal utility methods.
    protected
    
      def init
        session[:crud_star] ||= {}
        @subnav = nil
      end
    
      def validate_login
        if current_user.nil?
          session[:crud_star][:requested_page] = params
          session[:crud_star][:requested_page][:controller] = '/' + session[:crud_star][:requested_page][:controller]
          
          redirect_to :controller => 'crud_star/account', :action => 'login'
        else
          session[:crud_star][:requested_page] = nil
        end
      end
    
      def validate_access
        unless check_permissions
          redirect_to :controller => 'crud_star/index', :action => 'index'
        end
      end
      
      def current_user
        unless session[:crud_star][:username].nil? or session[:crud_star][:username].empty?
          User.where(:username => session[:crud_star][:username]).first
        end
      end

      def check_permissions
        if CrudStar::Engine.config.use_cancan
          check_permissions_from_cancan
        else
          check_permissions_from_controller
        end
      end

      def check_permissions_from_cancan
        CrudStar::Engine.config.ability_class.new(current_user).can?(action_name.to_sym, model)
      end

      def check_permissions_from_controller
        perms = permissions
        unless perms.nil?
          unless perms[session[:crud_star][:role].to_sym].nil?
            return perms[session[:crud_star][:role].to_sym].include?(action_name)
          end
          raise RuntimeError.new("You need to define #{session[:crud_star][:role]} permissions for #{action_name}")
        end
        raise RuntimeError.new("You need to define permissions for #{action_name}")
      end
  end
end
