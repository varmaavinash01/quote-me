class Quote
  class << self
    def get_all
      keys = REDIS.keys("quoteme:quote:*")
      quotes = []
      keys.each do |key|
        quotes.push(ActiveSupport::JSON.decode(REDIS.get(key)))
        Rails.logger.info ActiveSupport::JSON.decode(REDIS.get(key)).to_json
      end
      return quotes
    end

    def get(options)
      Rails.logger.info "in get" + options.inspect
      REDIS.get(create_key(options))
    end

    def save(quote)
      Rails.logger.info "in save"
      counter = REDIS.get("quoteme:quotecount").to_i + 1
      key = "quoteme:quote:" + counter.to_s
      quote["id"] = counter.to_s
      REDIS.set("quoteme:quotecount", counter.to_s)
      REDIS.set(key,quote.to_json)
    end

    def action(params)
      Rails.logger.info "[M][quote] in update"
      user_id = params["uid"]
      quote_id = params["id"]
      action = params["q_action"]
      user = ActiveSupport::JSON.decode(REDIS.get("quoteme:user:" + user_id))
      user["stat"][action].push(quote_id) unless user["stat"][action].include? quote_id
      REDIS.set("quoteme:user:" + user_id, user.to_json)
      
      quote = ActiveSupport::JSON.decode(REDIS.get("quoteme:quote:" + quote_id))
      quote[action]["users"].push(user_id) unless quote[action]["users"].include? user_id
      REDIS.set("quoteme:quote:" + quote_id, quote.to_json)
      ret = {"status" => "ok"}
      ret    
    end

    def delete(quote)
      Rails.logger.info "in delete"
      REDIS.delete(params[:key])
    end

    def create_key(options)
      Rails.logger.info "create_key " + options[:email]
      return "quoteme:quote:" + options[:quote_id]
    end
  end
end