AafDb::Application.routes.draw do

  resources :collection_groups do as_routes end

  resources :groups do as_routes end

  devise_for :users

  resources :collections do as_routes end

  resources :hyp_items do as_routes end

  resources :src_tables do as_routes end

  resources :wide_tables do 
    as_routes 
    collection do
      get 'search_tables'
      post 'find_results'
      get 'show_result'
      get 'update_results'
      get 'show_next'
      get 'add_to_cart'
      get 'remove_hyp'
      get 'view_hyp'
      get 'choose_cart'
      post 'add_to_group'
      post 'add_to_collection'
      get 'remove_hypothesis'
      post 'add_all_to_cart'
      get 'final_facts'
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'wide_tables#search_tables'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
