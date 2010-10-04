module CrudStar
  class IndexController < CrudStar::CrudController
  
    def permissions
      {:admin => ['index']}
    end
  
    def index
    
      path = CrudStar::Engine.config.url_path
      
      render CrudStar::Utility.get_template(File.join('index', 'index'))
      
    end
  end
end