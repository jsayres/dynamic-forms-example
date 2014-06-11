Rails.application.routes.draw do
  root 'static_pages#main'
  get '/subproject', to: 'static_pages#subproject'
  get '/admin', to: 'static_pages#admin'
  get '/admin/*details', to: 'static_pages#admin'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  namespace :api, defaults: {format: 'json'} do
    get '/projects', to: 'projects#index'

    get '/forms', to: 'forms#index', as: :forms
    post '/forms', to: 'forms#create'
    get '/forms/:number/versions', to: 'forms#versions', as: :form_versions
    get '/forms/:number/versions/:version', to: 'forms#version', as: :form_version
    put '/forms/:number/versions/:version', to: 'forms#update', as: :form_update
    post '/forms/:number/versions/:version/publish', to: 'forms#publish', as: :form_publish
    post '/forms/:number/versions/:version/unpublish', to: 'forms#unpublish', as: :form_unpublish
    get '/forms/:number/versions/:version/responses', to: 'forms#responses', as: :form_responses
  end

  get '/forms/:project', to: 'form_responses#project_forms', as: :project_forms
  get '/forms/:project/:slug', to: 'form_responses#new', as: :new_form_response
  post '/forms/:project/:slug', to: 'form_responses#create'
  get '/forms/:project/:slug/done', to: 'form_responses#done', as: :form_response_created

end
