Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root "recordings#index"
  
  get "/recordings", to: "recordings#index"
  get "/recordings/:id", to: "recordings#show", as: :show_summary

end
