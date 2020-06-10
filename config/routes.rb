Rails.application.routes.draw do
  # resources :location_registers
  # get 'home/index'
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  devise_scope :user do		
		get 'login', to: 'users/sessions#new'
		get 'logout', to: 'users/sessions#destroy'
		get 'users', to: 'users/registrations#new'
	end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "home#index"

  get 'show_location', to: 'location_registers#index'
  get 'share_location', to: 'location_registers#share_location'
  # Ajax method to save new location from map for the current logged in user
  post 'save_new_location', to: 'location_registers#save_new_location'
  # Ajax method to save location sharing in the mapping table
  post 'update_location_share', to: 'location_registers#update_location_share'
  # Ajax method to delete location with respect to location id and corresponding mappings
  post 'destroy_location', to: 'location_registers#destroy_location'  
  get 'users_list', to: 'home#users_list'
  get ':username', to: 'home#show_users_public_location'
 
  
end
