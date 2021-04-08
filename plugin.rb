# name: discourse-mentionable-items
# about: Takes a feed of items from a Google sheet and then allows users to +mention them in posts
# email contacts: robert@thepavilion.io
# version: 0.1
# authors: Robert Barrow
# url: https://github.com/paviliondev/discourse-mentionable-items

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
    ../lib/pretty_text_edits.rb
    ../models/mentionable_item_slug.rb
    ../models/mentionable_item.rb
    ../jobs/upload_mentionable_items.rb
    ../jobs/refresh_google_access_token.rb
  ).each do |path|
    load File.expand_path(path, __FILE__)

    class ::SiteSerializer
      attributes :mentionable_items
  
      def mentionable_items
        MentionableItem.all
      end
    end
  end
end
