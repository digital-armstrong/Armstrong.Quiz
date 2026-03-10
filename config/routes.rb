Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  get "up" => "rails/health#show", as: :rails_health_check
  get "privacy", to: "pages#privacy", as: :privacy

  root "home#index"
  get "profile", to: "profile#show", as: :profile

  namespace :admin do
    root "results#index", as: :root
    resources :users, only: %i[index show new create edit update destroy] do
      member do
        patch :ban
        patch :archive
        patch :activate
      end
    end
    resources :categories
    resources :questions do
      get :new_option_fields, on: :collection
      resources :answer_options, only: %i[new create edit update destroy], shallow: true
    end
    get "results", to: "results#index", as: :results
    get "results/:user_id", to: "results#show", as: :result
    patch "user_answers/:id", to: "user_answers#update", as: :user_answer
    get "evaluations/user/:user_id/new", to: "evaluations#new", as: :new_user_evaluation
    resources :evaluations, only: %i[create edit update]
    resources :evaluation_summaries, only: :index
  end

  resource :quiz, only: %i[show create], controller: "quiz" do
    post "answer", on: :member
  end
end
