# name: discourse-mentionable-items
# about: Takes a feed of items from a Google sheet and then allows users to +mention them in posts
# email contacts: robert@thepavilion.io
# version: 0.1
# authors: Robert Barrow
# url: https://github.com/paviliondev/discourse-mentionable-items

gem 'os', '1.1.1', { require: false }
gem 'memoist', '0.16.2', { require: false }
gem 'declarative-option', '0.1.0', { require: false }
gem 'declarative', '0.0.20', { require: false }
gem 'trailblazer-option', '0.1.0', { require: false }
gem 'uber','0.1.0', { require: false }
gem 'representable', '3.0.4', { require: false }
gem 'googleauth', '0.16.1', { require: false }
gem 'google-apis-core', '0.3.0', { require: false }
gem 'google-apis-discovery_v1', '0.2.0', { require: false }
gem 'google-apis-generator', '0.2.0', { require: false }
gem 'google-api-client', '0.53.0', { require: false }
gem 'google_drive', '3.0.6', { require: false }
gem 'jwt', '2.2.2', { require: false }
gem 'openssl', '2.2.0', { require: false }
gem 'base64url', '1.0.1', { require: false }
gem 'friendly_id', '5.4.2', {require: false }

enabled_site_setting :mentionable_items_enabled

register_asset 'stylesheets/common.scss'

after_initialize do
  %w(
    ../lib/engine.rb
    ../lib/worksheets_import.rb
    ../lib/google_authorization.rb
    ../lib/google_sheet_operations.rb
    ../lib/before_post_process_cooked_edits.rb
    ../serializers/site_serializer_edits.rb
    ../models/mentionable_item_slug.rb
    ../models/mentionable_item.rb
    ../jobs/upload_mentionable_items.rb
    ../jobs/refresh_google_access_token.rb
  ).each do |path|
    load File.expand_path(path, __FILE__)
  end
end
