LibreTPV::Application.routes.draw do
  # map.connect ':seccion/:controller/:action/:id'
  root to: 'albarans#index', seccion: 'caja', controller: 'albarans', action: 'index'
  match ':seccion/:controller(/:action(/:id))', via: [:get, :post]
  # map.root :seccion => "caja", :controller => "albarans"
end
