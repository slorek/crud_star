module CrudStar
  class AccountController < CrudStar::AdminController
  
    layout false
  
    def login
    
      flash[:errors] = []
    
      if request.post?
      
        if @user = User.authenticate(params[:user], params[:password])
        
          session[:username]  = @user.username
          session[:role]      = :admin
        
          
          unless session[:requested_page].nil?
          
            redirect_to session[:requested_page]
          else
            redirect_to :controller => '/crud_star/index'
          end
        else
          flash[:errors] << 'User name or password invalid.'
        end
      end
    
    end
  
  
    def logout
      session[:username]  = nil
      session[:role]      = nil
      redirect_to :controller => '/crud_star/index'
    end
  end
end