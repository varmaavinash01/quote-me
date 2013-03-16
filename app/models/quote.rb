class Quote
  class << self
    def get_all
      keys = REDIS.keys("quoteme:quote:*")
      quotes = []
      keys.each do |key|
        quotes.push(_read(key))
      end
      return quotes
    end

    def get(options)
      # not used
      Rails.logger.info "in get" + options.inspect
      REDIS.get(create_key(options))
    end

    def save(quote)
      Rails.logger.info "[M][Quote] in save"
      counter = REDIS.incr("quoteme:quotecount")
      key = "quote:" + counter.to_s
      quote["id"] = counter.to_s
      #REDIS.set(key,quote.to_json)
      _write(key,quote.to_json)
    end

    def action(params)
      Rails.logger.info "[M][quote] in update"
      user_id = params["uid"]
      quote_id = params["id"]
      action = params["q_action"]
      user = _read("user:" + user_id)
      user["stat"][action].push(quote_id) unless user["stat"][action].include? quote_id
      _write("user:" + user_id, user.to_json)

      quote = _read("quote:" + quote_id)
      quote[action]["users"].push(user_id) unless quote[action]["users"].include? user_id
      _write("quote:" + quote_id, quote.to_json)
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

    private

    def _write(key, value)
      key = "quoteme:" + key unless key.match("^quoteme:/*")
      REDIS.set(key,value)
    end

    def _read(key)
      key = "quoteme:" + key unless key.match("^quoteme:/*")
      ActiveSupport::JSON.decode(REDIS.get(key))
    end
  end
end