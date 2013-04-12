ElephantWebApp::Application.routes.draw do


    root to: 'static_pages#home'

    match '/help', to: 'static_pages#help'
    match '/features', to: 'static_pages#features'
    match '/about', to: 'static_pages#about'
    match '/sales', to: 'static_pages#sales'
    match '/overview', to: 'static_pages#overview', :via => :get
    match '/overview', to: 'static_pages#filter_overview', :via => :post
    match '/terms_of_use', to: 'static_pages#terms_of_use'

    resources :users, only: [:index, :show, :new, :create, :destroy, :edit, :update]

    resources :user_roles, only: [:index, :show, :new, :create, :destroy, :edit, :update]

    resources :sessions, only: [:create, :destroy]

    #match "/settings" => "settings#edit", :via => :get
    #match "/settings" => "settings#update", :via => :put
    resources :settings, only: [:edit, :update, :security, :update_security]
    match '/security', to: 'settings#security'
    match '/update_security', to: 'settings#update_security'

    match '/signin', to: 'sessions#new'
    get '/update_password', to: 'sessions#edit'
    match '/create_password', to: 'sessions#update', via: :post
    match '/signout', to: 'sessions#destroy', via: :delete
    match '/reset_password', to: 'sessions#reset_password'
    match '/verify_network', to: 'sessions#verify_network'

    resources :elephant_admin, only: [:index]
    match '/elephant_admin', to: 'elephant_admin#index'

    resources :companies, only: [:new, :destroy, :create, :show, :edit, :update]

    resources :job_templates, only: [:index, :new, :create, :destroy, :show, :edit, :update]

    resources :clients, only: [:index, :new, :create, :destroy, :show, :edit, :update]

    resources :districts, only: [:index, :new, :create, :destroy, :show, :edit, :update]

    resources :countries, only: [:show]

    resources :divisions, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    resources :segments, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    resources :product_lines, only: [:index, :show, :new, :create, :edit, :update, :destroy]

    resources :documents, only: [:show, :new, :create, :update, :destroy]

    resources :dynamic_fields, only: [:show, :new, :create, :edit, :update, :destroy]

    resources :activities, only: [:index]



    resources :jobs, only: [:index, :show, :new, :create, :update, :destroy]

    resources :fields, only: [:index, :show, :new, :create]

    resources :wells, only: [:index, :show, :new, :create, :edit, :update]



    resources :search, only: [:new, :create, :index]

    resources :history, only: [:index]

    resources :alerts, only: [:index]


    resources :job_notes, only: [:new, :create, :destroy]

    resources :job_memberships, only: [:new, :edit, :update, :create, :destroy]

    resources :job_note_comments, only: [:create, :destroy]

    resources :conversations, only: [:index, :show, :new, :create, :destroy, :update]

    resources :job_process, only: [:show, :update]

    resources :tools, only: [:new, :create, :update, :destroy]
    resources :primary_tools, only: [:create, :destroy]
    resources :secondary_tools, only: [:index, :new, :create, :destroy]

    resources :failures, only: [:index, :new, :create, :update, :destroy]

    resources :post_job_report_documents, only: [:create, :update, :destroy]

    resources :document_shares, only: [:index, :show, :new, :create, :destroy]

end

