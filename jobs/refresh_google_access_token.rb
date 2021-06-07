module Jobs
  class RefreshGoogleAccessToken < ::Jobs::Base
    def execute(args={})
      Mentionables::GoogleAuthorization.get_access_token
    end
  end
end
