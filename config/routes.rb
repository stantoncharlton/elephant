ElephantWebApp::Application.routes.draw do


    root to: 'static_pages#home'

    match '/help', to: 'static_pages#help'

    resources :users, only: [:show]

    get 'settings', to: 'users#settings', as: 'settings'


    resources :sessions, only: [:create, :destroy]

    match '/signin',  to: 'sessions#new'
    match '/signout', to: 'sessions#destroy', via: :delete

    resources :elephant_admin, only: [:index]

    resources :companies, only: [:new, :destroy, :create]

    get 'company', to: 'companies#show', as: 'company'
end
