require 'httparty'

module Booker
  BASE_HOST = "stable-app.secure-booker.com"
  BASE_PATH = "/WebService4/json/customerService.svc"

  class Client
    attr_reader :url, :access_token, :expires_in

    def initialize(key, secret)
      @key = key
      @secret = secret
      set_access_token
    end

    # POST
    #/availability/multispa
    #def appointments
      #url = "http://stable-app.secure-booker.com/WebService4/json/customerService.svc/availability/multispa"

      #options = { body: {
        #"access_token" => @access_token,
        #"TreatmentCategoryID" => 1,
        #"ZipCode" => 77077,
        #"Radius" => 25,
        #"StartDateTime" => "/Date(#{Time.now.to_i})/",
        #"EndDateTime" => "/Date(#{Time.now.to_i + 1728000 })/"
      #}.to_json, headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }
      #response = HTTParty.post url, options
      #p JSON.parse(response.body)
    #end

    # works
    def find_treatments location_id
      url = "http://stable-app.secure-booker.com/WebService4/json/customerService.svc/treatments"
      response = post url, {
        "access_token" => @access_token,
        "PageNumber" => 1,
        "PageSize" => 2,
        "UsePaging" => true,
        "LocationID" => location_id
      }
      p response['Treatments']
    end

    def find_locations_partial
      url = "http://stable-app.secure-booker.com/WebService4/json/customerService.svc/locations/partial"
      response = post url, {
        "access_token" => @access_token,
        "PageNumber" => 1,
        "PageSize" => 20,
      }
      p response['Results']
    end

    private

    def post url, post_data
      options = {
        body: post_data.to_json,
        headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
      }
      JSON.parse(HTTParty.post(url, options).body)
    end

    def set_access_token
      url      = build_url '/access_token', "?client_id=#{@key}&client_secret=#{@secret}&grant_type=client_credentials"
      response = HTTParty.get(url)
      body     = JSON.parse(response.body)

      if body['error']
        raise body['error'] + ":" + body['error_description']
      else
        @access_token = body['access_token']
        @expires_in = body['expires_in']
      end
    end

    def base_url
      "http://" + Booker::BASE_HOST + Booker::BASE_PATH
    end

    def build_url path, query = ''
      base_url + path + query
    end
  end
end
