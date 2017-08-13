Rails.application.routes.draw do
  mount Simplec::Engine => "/"

  scope module: :admin, as: :admin, constraints: { subdomain: 'admin' } do
    root 'static#dashboard'

    resources :subdomains, only: %w(index new create edit update destroy)
    resources :pages, only: %w(index new create edit update destroy)
    resources :documents, only: %w(index new create edit update destroy)
    resources :document_sets, only: %w(index new create edit update destroy)
    resources :embedded_images, only: %w(create) # TODO nice to put this in gem

    resource :session, only: %w(new create destroy)
  end

end
