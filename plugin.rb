# frozen_string_literal: true
# name: discourse-mentionables
# about: Allows users to +mention custom data in posts
# email contacts: robert@thepavilion.io
# version: 0.4.1
# authors: Robert Barrow, Angus McLeod
# contact_emails: development@pavilion.tech
# url: https://github.com/paviliondev/discourse-mentionables

gem 'gems', '1.2.0', require: false
gem 'webrick', '1.7.0', require: false
gem 'rexml', '3.2.5', require: false
gem 'httpclient', '2.8.3', require: false
gem 'retriable', '3.1.2', require: false
gem 'signet', '0.17.0', require: false
gem 'os', '1.1.1', require: false
gem 'memoist', '0.16.2', require: false
gem 'declarative-option', '0.1.0', require: false
gem 'declarative', '0.0.20', require: false
gem 'trailblazer-option', '0.1.0', require: false
gem 'uber', '0.1.0', require: false
gem 'representable', '3.0.4', require: false
gem 'googleauth', '0.16.0', require: false
gem 'google-apis-core', '0.3.0', require: false
gem 'google-apis-discovery_v1', '0.2.0', require: false
gem 'google-apis-generator', '0.2.0', require: false
gem 'google-api-client', '0.53.0', require: false
gem 'google_drive', '3.0.6', require: false
gem 'base64url', '1.0.1', require: false

enabled_site_setting :mentionables_enabled
add_admin_route "mentionables.title", "mentionables"
register_asset 'stylesheets/common.scss'

#added svg icons
register_svg_icon 'shopping-cart'

after_initialize do
  %w(
    ../lib/mentionables/engine.rb
    ../lib/mentionables/source.rb
    ../lib/mentionables/sources/google/google_authorization.rb
    ../lib/mentionables/sources/google/google_sheets.rb
    ../lib/mentionables/import_result.rb
    ../lib/mentionables/log.rb
    ../lib/mentionables/post_process.rb
    ../app/controllers/mentionables/admin_controller.rb
    ../app/serializers/mentionables/log_serializer.rb
    ../app/models/mentionable_item.rb
    ../config/routes.rb
    ../jobs/import_mentionable_items.rb
    ../jobs/destroy_mentionable_items.rb
    ../jobs/refresh_google_access_token.rb
  ).each do |path|
    load File.expand_path(path, __FILE__)
  end

  add_to_serializer(:site, :mentionable_items) do
    MentionableItem.all
  end

  on(:before_post_process_cooked) do |doc, post|
    Mentionables::PostProcess.add_links(doc, post)
  end
end

DiscourseEvent.on(:custom_wizard_ready) do
  if defined?(CustomWizard) == 'constant' && CustomWizard.class == Module
    CustomWizard::Field.register('mentionables', 'discourse-mentionables', ['models', 'lib', 'stylesheets', 'templates'])
    CustomWizard::WizardSerializer.attributes("mentionable_items")
    CustomWizard::WizardSerializer.public_send(:define_method, "include_mentionable_items?") { SiteSetting.mentionables_enabled }
    CustomWizard::WizardSerializer.public_send(:define_method, "mentionable_items") { MentionableItem.all }
  end
end
