Simplec::Engine.routes.draw do

  scope constraints: Simplec::Subdomains do
    root 'pages#show'
    get '*path', to: 'pages#show'
  end

end
