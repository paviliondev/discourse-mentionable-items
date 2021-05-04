Discourse::Application.routes.append do
  get '/admin/plugins/mentionable-items' => 'mentionable_items/admin#index', constraints: AdminConstraint.new
  post '/admin/plugins/mentionable-items' => 'mentionable_items/admin#import', constraints: AdminConstraint.new
  delete '/admin/plugins/mentionable-items' => 'mentionable_items/admin#destroy', constraints: AdminConstraint.new
end