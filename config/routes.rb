Discourse::Application.routes.append do
  get '/admin/plugins/mentionables' => 'mentionables/admin#index', constraints: AdminConstraint.new
  post '/admin/plugins/mentionables' => 'mentionables/admin#import', constraints: AdminConstraint.new
  delete '/admin/plugins/mentionables' => 'mentionables/admin#destroy', constraints: AdminConstraint.new
end