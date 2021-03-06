require "wepay_ruby_sdk/version"

module WepayRubySdk
  require 'rubygems'
  require 'uri'
  require 'json'
  require 'net/http'
  require 'net/https'
  require 'cgi'

  class Api
    
    STAGE_API_ENDPOINT = "https://stage.wepayapi.com/v2"
    STAGE_UI_ENDPOINT = "https://stage.wepay.com/v2"
    
    PRODUCTION_API_ENDPOINT = "https://wepayapi.com/v2"
    PRODUCTION_UI_ENDPOINT = "https://www.wepay.com/v2"
      
    # initializes the API application, api_endpoint should be something like 'https://stage.wepay.com/v2'
    def initialize(_client_id, _client_secret, _use_stage = true, _use_ssl = true)
      @client_id = _client_id
      @client_secret = _client_secret
      if _use_stage
        @api_endpoint = STAGE_API_ENDPOINT
        @ui_endpoint = STAGE_UI_ENDPOINT
      else
        @api_endpoint = PRODUCTION_API_ENDPOINT
        @ui_endpoint = PRODUCTION_UI_ENDPOINT
      end
      @use_ssl = _use_ssl
    end
    
    # make a call to the WePay API
    def call(call, access_token = false, params = false)
      # get the url
      url = URI.parse(@api_endpoint + call)
      # construct the call data and access token
      call = Net::HTTP::Post.new(url.path, initheader = {'Content-Type' =>'application/json'})
      if params
        call.body = params.to_json
      end
      if access_token
        call.add_field('Authorization: Bearer', access_token);
      end
      # create the request object
      request = Net::HTTP.new(url.host, url.port)
      request.use_ssl = @use_ssl
      # make the call
      response = request.start {|http| http.request(call) }
      # returns JSON response as ruby hash
      symbolize_response(response.body)
    end

    def symbolize_response(response)
      json = JSON.parse(response)
      if json.kind_of? Hash
        # json.symbolize_keys! and raise_if_response_error(json)
        json.symbolize_keys!
      elsif json.kind_of? Array
        json.each{|h| h.symbolize_keys!}
      end
      json
    end

    def raise_if_response_error(json)
      if json.has_key?(:error) && json.has_key?(:error_description)
        if ['invalid code parameter','the code has expired','this access_token has been revoked', 'a valid access_token is required'].include?(json[:error_description])
          raise WepayRails::Exceptions::ExpiredTokenError.new("Token either expired, revoked or invalid: #{json[:error_description]}")
        else
          raise WepayRails::Exceptions::WepayApiError.new(json[:error_description])
        end
      end
    end


    # this function returns the URL that you send the user to to authorize your API application
    # the redirect_uri must be a full uri (ex https://www.wepay.com)
    def oauth2_authorize_url(redirect_uri, user_email = false, user_name = false, permissions = "manage_accounts,view_balance,collect_payments,refund_payments,view_user")
      url = @ui_endpoint + '/oauth2/authorize?client_id=' + @client_id.to_s + '&redirect_uri=' + redirect_uri + '&scope=' + permissions
      url += user_name ? '&user_name=' + CGI::escape(user_name) : ''
      url += user_email ? '&user_email=' + CGI::escape(user_email) : ''
    end
    
    #this function will make a call to the /v2/oauth2/token endpoint to exchange a code for an access_token
    def oauth2_token(code, redirect_uri)
      call('/oauth2/token', false, {'client_id' => @client_id, 'client_secret' => @client_secret, 'redirect_uri' => redirect_uri, 'code' => code })
    end
    
  end
end
