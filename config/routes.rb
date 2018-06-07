Rails.application.routes.draw do
	root 'users#index'
  	resources :users
  	get 'user_voice' => 'users#voice'
  	get 'speech_to_text' => 'users#speech_to_text'
  	get 'call' => 'users#call'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
