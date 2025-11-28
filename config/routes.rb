Rails.application.routes.draw do
  resources :products do
    post :sync, on: :collection
    post :sync_to_sheet, on: :collection
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
