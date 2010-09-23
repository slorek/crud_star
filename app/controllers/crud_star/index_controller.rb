module CrudStar
  class IndexController < CrudStar::CrudController
  
    def selected_tab
      'Dashboard'
    end
  
    def permissions
      {:admin => ['index']}
    end
  
    def index
    
    
    
    end
  end
end