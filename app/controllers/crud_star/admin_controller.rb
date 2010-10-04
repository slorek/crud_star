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
        @subnav = nil
      end
    
      def validate_login
        if session[:username].nil? or session[:username].empty?
        
          session[:requested_page] = params
          session[:requested_page][:controller] = '/' + session[:requested_page][:controller]
          
          redirect_to :controller => 'crud_star/account', :action => 'login'
        else
          session[:requested_page] = nil
        end
      end
    
      def validate_access
        unless permissions[session[:role]].include? self.action_name
          redirect_to :controller => 'crud_star/index', :action => 'index'
        end
      end
  end
end