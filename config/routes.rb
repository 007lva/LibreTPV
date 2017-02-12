LibreTPV::Application.routes.draw do
  root :to => 'albaranes#index', :seccion => "caja", :controller => "albaranes", :action => "index"
  # map.connect ':seccion/:controller/:action/:id'
  match ':seccion/:controller(/:action(/:id))'
  # map.root :seccion => "caja", :controller => "albaranes"
end
