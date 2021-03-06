Rails.application.routes.draw do
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	root 'sitings#index'
	resources :sitings do
		resources :comments
		member do
		    get "like"
		    get "unlike"
		end
	end

	get 'map' => 'pages#map'

	get 'users/:id' => 'users#show', as: :users

	devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }, path: '', path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'register' }
end
