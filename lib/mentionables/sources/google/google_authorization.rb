# frozen_string_literal: true

require 'googleauth'
# require 'googleauth/stores/file_token_store'

class Mentionables::GoogleAuthorization
  SCOPES = %w(
    https://www.googleapis.com/auth/spreadsheets.readonly
    https://www.googleapis.com/auth/drive.readonly
  )
  BASE_API_URL = 'https://accounts.google.com/o/oauth2/auth'
  TOKEN_URL = 'https://oauth2.googleapis.com/token'

  def self.authorizer
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(Mentionables::GoogleAuthorization.credentials),
      scope: SCOPES)
  end

  def self.credentials
    {
      type: "service_account",
      private_key: SiteSetting.mentionables_google_service_account_private_key,
      client_email: SiteSetting.mentionables_google_service_account_email,
      auth_uri: BASE_API_URL,
      token_uri: BASE_API_URL,
    }.to_json
  end
end
