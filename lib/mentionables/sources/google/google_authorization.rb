# frozen_string_literal: true
require 'excon'
require 'jwt'
require "base64url"

class Mentionables::GoogleAuthorization
  SCOPES = %w(
    https://www.googleapis.com/auth/spreadsheets.readonly
    https://www.googleapis.com/auth/drive.readonly
  )
  BASE_API_URL = 'https://oauth2.googleapis.com/'
  TOKEN_URL = "https://oauth2.googleapis.com/token"
  GRANT_TYPE = "urn:ietf:params:oauth:grant-type:jwt-bearer"

  def self.access_token
    request_access_token if !authorized
    get_access_token[:token]
  end

  def self.set_access_token(data)
    PluginStore.set(Mentionables::PLUGIN_NAME, 'google_sheets_access_token', data)
  end

  def self.get_access_token
    PluginStore.get(Mentionables::PLUGIN_NAME, 'google_sheets_access_token') || {}
  end

  def self.calculate_jwt
    header = { "alg": "RS256", "typ": "JWT" }
    headerJWT = Base64URL.encode(JSON.generate(header))
    claims = {
      "iss": SiteSetting.mentionables_google_service_account_email,
      "scope": SCOPES.join(" "),
      "aud": TOKEN_URL,
      "exp": Time.now.to_i + 3600,
      "iat": Time.now.to_i,
    }
    claimsJWT = Base64URL.encode(JSON.generate(claims))
    private_key = SiteSetting.mentionables_google_service_account_private_key
    rsa_public = OpenSSL::PKey::RSA.new(private_key.gsub("\\n", "\n"))
    sig = JWT::Signature.sign('RS256', "#{headerJWT}.#{claimsJWT}", rsa_public)
    sig64 = Base64URL.encode(sig)

    "#{headerJWT}.#{claimsJWT}.#{sig64}"
  end

  def self.request_access_token
    token = calculate_jwt
    body = {
      grant_type: GRANT_TYPE,
      assertion: token
    }

    result = Excon.post("#{BASE_API_URL}/token",
      headers: {
        "Content-Type" => "application/x-www-form-urlencoded"
      },
      body: URI.encode_www_form(body)
    )

    handle_token_result(result)
  end

  def self.handle_token_result(result)
    data = JSON.parse(result.body)

    return false if (data['error'])

    token = data['access_token']
    expires_at = Time.now + data['expires_in'].seconds
    refresh_at = expires_at.to_time - 1.minutes

    Jobs.enqueue_at(refresh_at, :refresh_google_access_token)

    set_access_token(
      token: token,
      expires_at: expires_at,
      refresh_at: refresh_at
    )
  end

  def self.authorized
    stored = get_access_token
    stored[:token] && stored[:expires_at].to_datetime > Time.now
  end
end
