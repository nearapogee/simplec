Simplec::Engine.routes.draw do

  scope constraints: Simplec::Subdomains do
    resources :embedded_images, path: 'embedded-images', only: :create
    root 'pages#show'
    get '*path', to: 'pages#show'
  end

end
