ElephantWebApp::Application.routes.draw do


    root to: 'static_pages#home'

    match '/help', to: 'static_pages#help'
    match '/features', to: 'static_pages#features'
    match '/about', to: 'static_pages#about'
    match '/sales', to: 'static_pages#sales'
    match '/overview', to: 'overview#overview', :via => :get
    match '/overview', to: 'overview#filter_overview', :via => :post
    match '/terms_of_use', to: 'static_pages#terms_of_use'
    match '/tutorial', to: 'static_pages#tutorial'

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

    resources :dynamic_fields, only: [:index, :show, :new, :create, :edit, :update, :destroy]

    resources :activities, only: [:index, :show]



    resources :jobs, only: [:index, :show, :new, :create, :update, :destroy]

    resources :fields, only: [:index, :show, :new, :create]

    resources :wells, only: [:index, :show, :new, :create, :edit, :update]



    resources :search, only: [:new, :create, :index]

    resources :history, only: [:index]
    resources :insight, only: [:index]

    resources :alerts, only: [:index]


    resources :job_notes, only: [:new, :create, :destroy]

    resources :job_memberships, only: [:new, :edit, :update, :create, :destroy]

    resources :job_note_comments, only: [:create, :destroy]

    resources :conversations, only: [:index, :show, :new, :create, :destroy, :update]

    resources :job_process, only: [:show, :update]

    resources :tools, only: [:new, :create, :edit, :update, :destroy]
    resources :primary_tools, only: [:create, :destroy, :show]
    resources :secondary_tools, only: [:index, :new, :create, :destroy]

    resources :failures, only: [:index, :new, :show, :create, :update, :destroy]

    resources :post_job_report_documents, only: [:create, :update, :destroy]

    resources :document_shares, only: [:index, :show, :new, :create, :update, :destroy]


    # Inventory
    resources :inventory, only: [:index, :show]
    resources :parts, only: [:index, :show, :new, :create, :update, :destroy]

    resources :part_memberships, only: [:new, :create, :update, :destroy]


    resources :job_logs, only: [:index, :create, :show]

    resources :job_times, only: [:index, :update]
end

