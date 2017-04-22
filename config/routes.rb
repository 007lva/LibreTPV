LibreTPV::Application.routes.draw do
  root to: 'albarans#index', seccion: 'caja', controller: 'albarans', action: 'index'
  match ':seccion/:controller(/:action(/:id))', via: [:get, :post]
end
