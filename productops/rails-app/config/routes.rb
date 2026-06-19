Rails.application.routes.draw do
  root "dashboard#index"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :projects do
    resources :requirements, shallow: true do
      resources :requirement_gaps, only: %i[create update]
      resources :clarification_questions, only: %i[create update]
      resources :decision_notes, only: %i[create]
      resources :wbs_items
    end
    resources :sprints, only: %i[index show]
    resources :releases
  end
  resources :build_runs, only: %i[index create]
  resources :svn_imports, only: %i[new create]
  resources :audit_logs, only: %i[index]

  namespace :api do
    resources :projects, only: %i[index] do
      resources :sprints, only: %i[index]
    end
    get "sprints/:id/board", to: "sprints#board", as: :sprint_board
    post "sprints/:id/calculate_risk", to: "sprints#calculate_risk", as: :sprint_calculate_risk
    patch "wbs_items/:id/status", to: "wbs_items#status", as: :wbs_item_status
    patch "wbs_items/:id/actual_hours", to: "wbs_items#actual_hours", as: :wbs_item_actual_hours
    post "wbs_items/:id/dependencies", to: "wbs_items#create_dependency"
    delete "wbs_items/:id/dependencies/:dependency_id", to: "wbs_items#destroy_dependency"
    post "releases/:id/checklist", to: "releases#checklist", as: :release_checklist
    post "releases/:id/approve_production", to: "releases#approve_production", as: :release_approve_production
    post "svn/import", to: "svn#import"
    post "ant_builds/import", to: "ant_builds#import"
  end
end
