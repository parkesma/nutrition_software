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
  
  resources :exchanges, only: [:index, :create, :update, :destroy]
  resources :sub_exchanges, only: [:create, :update, :destroy]
  resources :foods, only: [:new, :create, :edit, :update, :destroy]
  resources :meals, only: [:index, :create, :update, :destroy]
  resources :food_assignments, only: [:create, :update, :destroy]
  
  post '/move_food_up',    to: 'food_assignments#move_food_up',   as: 'move_food_up'
  post '/move_food_down',  to: 'food_assignments#move_food_down', as: 'move_food_down'

  resources :supplement_brands, only: [:create, :update, :destroy]
  resources :supplement_products, only: [:create, :update, :destroy]
  resources :supplement_assignments, only: [:index, :create, :update, :destroy]
  
  get  '/import_all',                 to: 'users#import_all',           as: 'import_all'
  post '/import_users',               to: 'users#import',               as: 'import_users'
  post '/import_exchanges',           to: 'exchanges#import',           as: 'import_exchanges'
  post '/import_sub_exchanges',       to: 'sub_exchanges#import',       as: 'import_sub_exchanges'
  post '/import_foods',               to: 'foods#import',               as: 'import_foods'
  post '/import_supplement_brands',   to: 'supplement_brands#import',   as: 'import_supplement_brands'
  post '/import_supplement_products', to: 'supplement_products#import', as: 'import_supplement_products'
  post '/import_exercises',           to: 'exercises#import',           as: 'import_exercises'

  resources :videos, only: [:index, :create, :update, :destroy]
  
  post '/move_video_up',    to: 'videos#move_up',   as: 'move_video_up'
  post '/move_video_down',  to: 'videos#move_down', as: 'move_video_down'
  
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
