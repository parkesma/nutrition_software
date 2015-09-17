Rails.application.routes.draw do
  root                     'sessions#new'

  get '/login',        to: 'sessions#new',              as: 'login'
  post '/login',       to: 'sessions#create',           as: 'signin'
  delete '/logout',    to: 'sessions#destroy',          as: 'logout'

  resources :users
  get '/search',       to: 'users#search',              as: 'search'
  post '/search',      to: 'users#find',                as: 'find'
  get '/basic_info',   to: 'users#basic_info',          as: 'basic_info'
  patch '/basic_info', to: 'users#update_basic_info',   as: 'recalculate'

  resources :notes
  resources :measurements
  resources :fat_measurements
  
  post '/change_method', to: 'fat_measurements#change_method', as: 'change_method'
  
  resources :exercises
  resources :exercise_assignments, only: [:index, :create, :update, :destroy]
  
  post '/move_up',    to: 'exercise_assignments#move_up',   as: 'move_up'
  post '/move_down',  to: 'exercise_assignments#move_down', as: 'move_down'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
