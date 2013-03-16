class UsersController < ApplicationController
  APPID = 338841676234451
  SECRET = "eb1397523a9fac1836d6707a030db8b1" 
  
  def index
    @auth = Koala::Facebook::OAuth.new(APPID, SECRET, "http://knowyourpolitician.in:4000/users/callback")
    @fb_login_url = @auth.url_for_oauth_code(:permissions => "email,publish_stream")
  end
  
  def home
    @user = User.get(current_user)
    Rails.logger.info "[USER] = " + @user["info"]["id"]
    @quotes = Quote.get_all
    #post_on_fb
  end
 
  def quote_save
  end
  
  def callback
    @oauth = Koala::Facebook::OAuth.new(APPID, SECRET, "http://knowyourpolitician.in:4000/users/callback")
    session[:access_token] = @oauth.get_access_token(params[:code]) if params[:code]
    if session[:access_token]
      @user = User.get(current_user)
      flash[:notice] = "Logged in successfully"
      Rails.logger.info "[callback] " + @user.to_json
      #Rails.logger.info "[callback] stat agree = " + @user["stat"]["agree"].to_json
    else
      flash[:notice] = "Error logging in"
    end
    redirect_to :action => "home"
  end
  
  def logout
    session[:access_token] = nil
    flash[:notice] = "Logged out"
    redirect_to :action => "index"
  end
  
  def current_user
    return session[:access_token]
  end
  
  def post_on_fb
    @graph = Koala::Facebook::API.new(current_user)
    @user = @graph.get_object("me")
    options = {
          :message => "Quote by Avi\n\n" + @user["quotes"].split("\n")[0].to_s
        }
    begin
      @graph.put_object("me", "feed", options)
    rescue
      Rails.logger.error "Failed to post on FB."
    end        
  end
end
