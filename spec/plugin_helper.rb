# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  root "plugins/discourse-mentionable-items"
  track_files "plugins/discourse-mentionable-items/**/*.rb"
  add_filter { |src| src.filename =~ /(\/spec\/|\/db\/|plugin\.rb)/ }
end

require 'rails_helper'
