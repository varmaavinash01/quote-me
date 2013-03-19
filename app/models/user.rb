class User
  class << self
    def get(current_user)
      #Rails.logger.info "[M][get] called with current_user = " + current_user.to_s
      @graph = Koala::Facebook::API.new(current_user)
      @user = {}
      #Rails.logger.info "redis response = " + REDIS.get("quoteme:user:" + @graph.get_object("me")["id"] ).to_s
      if REDIS.get("quoteme:user:" + @graph.get_object("me")["id"] )
        # user exists, return it
        @user = ActiveSupport::JSON.decode(REDIS.get("quoteme:user:" + @graph.get_object("me")["id"] ))
      else
        @user = create_new(@graph.get_object("me"))
        key = "quoteme:user:" + @user["info"]["id"]
        REDIS.set(key,@user.to_json)
        Rails.logger.info "[M][get] New user = " + @user.to_json
      end
      @user
    end
    
    def get_from_id(user_id)
      @user = ActiveSupport::JSON.decode(REDIS.get("quoteme:user:" + @graph.get_object("me")["id"] ))
    end

    def create_new(user)
      #Rails.logger.info "[M][create_new] called with user = " + user.to_json
      ret_user = {}
      info = {}

      info["id"]       = user["id"]
      info["name"]     = user["name"]
      info["location"] = user["location"]["name"]
      info["gender"]   = user["gender"]
      info["email"]    = user["email"]

      stat = { "agree"    => [],
               "disagree" => [],
               "whatever" => [],
               "collect"  => []
             }

      ret_user["info"] = info
      ret_user["stat"] = stat

      ret_user
    end
  end
end