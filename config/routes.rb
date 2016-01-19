Rails.application.routes.draw do
  edgarj_resources :user_group_users

  namespace :edgarj do
    edgarj_popup_resources :users_popup
    edgarj_popup_resources :user_groups_popup

    edgarj_resources :model_permissions
    edgarj_resources :sssns
    edgarj_resources :user_groups
    edgarj_resources :user_group_users
  end

  get :top, to: 'edgarj/edgarj#top'
end
