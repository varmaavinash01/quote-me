class QuotesController < ApplicationController
  respond_to :json, :html
  
  def index
    
  end
  
  def show
    Rails.logger.info "[C][Quotes] Show called.with " + params.inspect
    options = {
                :email    => params[:email],
                :dateTo   => params[:dateTo],
                :dateFrom => params[:dateFrom]
              }
              
    respond_with Quote.get(options)
  end

  def create
    Rails.logger.info "[C][Quotes] CREATE called with " + params.inspect
    quote = {
                "content"  => params[:content],
                "author"   => params[:author],
                "agree"    => { "users" => []},
                "disagree" => { "users" => []},
                "whatever" => { "users" => []},
                "collect"  => { "users" => []}  
               }
    respond_with Quote.save(quote)
  end

  def destroy
    Rails.logger.info "DESTROY called"
    respond_with Quote.delete(key)
  end

  def update
    Rails.logger.info "[C][Quotes] UPDATE called with " + params.inspect
    respond_with Quote.action(params)
  end
end

