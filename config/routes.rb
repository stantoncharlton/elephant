ElephantWebApp::Application.routes.draw do


    root to: 'static_pages#home'

    match '/help', to: 'static_pages#help'
    match '/about', to: 'static_pages#about'
    match '/sales', to: 'static_pages#sales'

    resources :users, only: [:show, :new, :create]

    get 'settings', to: 'users#settings', as: 'settings'


    resources :sessions, only: [:create, :destroy]

    match '/signin',  to: 'sessions#new'
    match '/signout', to: 'sessions#destroy', via: :delete

    resources :elephant_admin, only: [:index]
    match '/elephant_admin',  to: 'elephant_admin#index'

    resources :companies, only: [:new, :destroy, :create, :show]
    get 'company', to: 'companies#show', as: 'company'
end
