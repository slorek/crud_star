module CrudStar
  class IndexController < CrudStar::CrudController
  
    def permissions
      {:admin => ['index']}
    end
  
    def index
    
    
    
    end
  end
end