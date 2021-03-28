module Jobs
  class RefreshGoogleAccessToken < ::Jobs::Base
    def execute(args={})
      MentionableItems::GoogleAuthorization.get_access_token
    end
  end
end
