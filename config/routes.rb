# Provides default admin routes to the application.
#
Rails.application.routes.draw do |map|

  path = CrudStar::Engine.config.url_path
  
  scope :module => 'crud_star' do
    
    if path.empty?
      root :to => "index#index"
    else
      match path => 'index#index'
    end
    
    match path + '/dashboard' => 'index#index'
    match path + '/login' => 'account#login'
    match path + '/logout' => 'account#logout'
  end
end