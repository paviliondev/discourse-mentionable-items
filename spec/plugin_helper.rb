# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  root "plugins/discourse-mentionables"
  track_files "plugins/discourse-mentionables/**/*.rb"
  add_filter { |src| src.filename =~ /(\/spec\/|\/db\/|plugin\.rb)/ }
end

require 'rails_helper'
