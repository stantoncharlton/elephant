ElephantWebApp::Application.routes.draw do


    root to: 'static_pages#home'

    match '/help', to: 'static_pages#help'
    match '/features', to: 'static_pages#features'
    match '/about', to: 'static_pages#about'
    match '/sales', to: 'static_pages#sales'
    match '/overview', to: 'overview#overview', :via => :get
    match '/insight', to: 'explore#index', :via => :get
    match '/overview', to: 'overview#filter_overview', :via => :post
    match '/terms_of_use', to: 'static_pages#terms_of_use'
    match '/tutorial', to: 'static_pages#tutorial'
    match '/terms', to: 'static_pages#terms'
    match '/privacy', to: 'static_pages#privacy'
    match '/copyright', to: 'static_pages#copyright'

    match '/pusher/auth', to: 'pusher#auth'

    resources :users, only: [:index, :show, :new, :create, :destroy, :edit, :update]

    resources :user_roles, only: [:index, :show, :new, :create, :destroy, :edit, :update]

    resources :sessions, only: [:create, :destroy]

    #match "/settings" => "settings#edit", :via => :get
    #match "/settings" => "settings#update", :via => :put
    resources :settings, only: [:edit, :update, :security, :update_security]
    match '/security', to: 'settings#security'
    match '/update_security', to: 'settings#update_security'

    match '/signin', to: 'sessions#new'
    match '/is_signed_in', to: 'sessions#show'
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
    resources :rigs, only: [:index, :new, :create, :show]



    resources :search, only: [:new, :create, :index]

    resources :history, only: [:index]
    resources :insight, only: [:index]

    resources :alerts, only: [:index]


    resources :job_notes, only: [:new, :create, :destroy]

    resources :job_memberships, only: [:new, :edit, :update, :create, :destroy]

    resources :job_note_comments, only: [:create, :destroy]

    resources :conversations, only: [:index, :show, :new, :create, :destroy, :update]

    resources :tools, only: [:new, :create, :edit, :update, :destroy]
    resources :primary_tools, only: [:index, :create, :destroy, :show, :update]
    resources :secondary_tools, only: [:index, :new, :create, :update, :destroy]

    resources :failures, only: [:index, :new, :show, :create, :edit, :update, :destroy]

    resources :post_job_report_documents, only: [:create, :update, :destroy]

    resources :document_shares, only: [:index, :show, :new, :create, :update, :destroy]


    # Inventory
    resources :inventory, only: [:index, :show]
    resources :parts, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    resources :warehouses, only: [:show, :new, :create, :edit, :update, :destroy]
    resources :suppliers, only: [:show, :new, :create, :edit, :update, :destroy]
    resources :warehouse_memberships, only: [:new, :edit, :update, :create, :destroy]

    resources :part_memberships, only: [:new, :create, :edit, :update, :destroy]


    resources :job_logs, only: [:index, :create, :show]
    resources :drilling_logs, only: [:index, :show]
    resources :drilling_log_entries, only: [:show, :new, :create, :show, :edit, :update, :destroy]

    resources :job_times, only: [:index, :update]


    resources :bhas, only: [:show, :new, :create, :edit, :update, :destroy]

    resources :issues, only: [:index, :show, :create, :edit, :update, :destroy]

    resources :surveys, only: [:index, :new, :create, :show, :edit, :update, :destroy]
    resources :survey_points, only: [:new, :create, :edit, :update, :destroy]

    resources :rig_memberships, only: [:new, :create, :destroy]

    resources :shipments, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    resources :shippers, only: [:index, :show, :new, :create, :edit, :update, :destroy]

    resources :asset_lists, only: [:index, :show]
    resources :asset_list_entries, only: [:show, :new, :create, :edit, :update, :destroy]

    resources :job_costs, only: [:index, :show, :new, :create, :edit, :update, :destroy]

    match '/report_status/:id', to: 'reports#status', :via => :get

    resources :survey_projections, only: [:new, :create]

end

