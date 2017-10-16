Simplec::Engine.routes.draw do

  scope constraints: Simplec::Subdomains do
    get '/sitemap', to: 'sitemaps#show',
      format: :xml,
      constraints: {subdomain: [nil, 'www']}

    resources :embedded_images, path: 'embedded-images', only: :create

    root 'pages#show'
    get '(*path)', to: 'pages#show', as: :page
  end

end
