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

    # http://apidoc.booker.com/Method/Detail/123
    def find_treatments options = {}
      url = "http://stable-app.secure-booker.com/WebService4/json/customerService.svc/treatments"
      defaults = {
        "access_token" => @access_token,
        "AllowOnGiftCertificateSale" => nil,
        "CategoryID" => nil,
        "EmployeeID" => nil,
        "LocationID" => nil,
        "PageNumber" => 1,
        "PageSize" => 10,
        "SortBy" => [
          {
            "SortBy" => "Name",
            "SortDirection" => 0
          }
        ],
        "SubCategoryID" => nil,
        "UsePaging" => true,
        "ExcludeClassesAndWorkshops" => nil,
        "OnlyClassesAndWorkshops" => nil,
        "SkipLoadingRoomsAndEmployees" => nil,
      }
      return_response url, defaults, options
    end

    # http://apidoc.booker.com/Method/Detail/853
    def find_locations_partial options = {}
      url = "http://stable-app.secure-booker.com/WebService4/json/customerService.svc/locations/partial"
      defaults = {
        "access_token" => @access_token,
        "BusinessTypeId" => nil,
        "PageNumber" => 1,
        "PageSize" => 5,
        "SortBy" => [
          {
            "SortBy" => "Name",
            "SortDirection" => 0
          }
        ],
        #"UsePaging" => true, # throws a weird exception about null arguments
        "Name" => nil
      }
      return_response url, defaults, options
    end


    private

      def return_response url, defaults, options
        options = defaults.merge(options)
        response = post url, options
        JSON.parse(response.body)
      end

      def post url, post_data
        options = {
          body: post_data.to_json,
          headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
        }
        HTTParty.post(url, options)
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
