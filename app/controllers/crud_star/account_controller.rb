module CrudStar
  class AccountController < CrudStar::AdminController
  
    layout false
  
    def login
    
      flash[:errors] = []
    
      if request.post?
      
        if @user = User.authenticate(params[:user], params[:password])
        
          session[:crud_star][:username]  = @user.username
          session[:crud_star][:role]      = :admin
        
          
          unless session[:crud_star][:requested_page].nil?
          
            redirect_to session[:crud_star][:requested_page]
          else
            redirect_to :controller => '/crud_star/index'
          end
        else
          flash[:errors] << 'User name or password invalid.'
        end
      end
    
    end
  
  
    def logout
      session[:crud_star][:username]  = nil
      session[:crud_star][:role]      = nil
      redirect_to :controller => '/crud_star/index'
    end
  end
end