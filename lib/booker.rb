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

    #http://apidoc.booker.com/Method/Detail/129
    def run_multi_service_availability options = {}
      raise Booker::ArgumentError, 'Itineraries is required' unless options['Itineraries']
      url = build_url "/availability/multiservice"
      defaults =
        {
        "access_token" => @access_token,
        "EndDateTime" => "/Date(#{Time.now.to_i})/",
        "Itineraries" => [
          #{
            #"IsPackage" => false,
            #"PackageID" => nil,
            #"Treatments" => [
              #{
                #"EmployeeID" => nil,
                #"TreatmentID" => nil
              #}
            #]
          #}
        ],
        "LocationID" => nil,
        "MaxTimesPerDay" => nil,
        "StartDateTime" => "/Date(#{Time.now.to_i + 60 * 60 * 24})/",
      }
      return_post_response url, defaults, options
    end

    # http://apidoc.booker.com/Method/Detail/123
    def find_treatments options = {}
      raise Booker::ArgumentError, 'LocationID is required' unless options['LocationID']
      url = build_url "/treatments"
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
      return_post_response url, defaults, options
    end

    # http://apidoc.booker.com/Method/Detail/853
    def find_locations_partial options = {}
      url = build_url "/locations/partial"
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
      return_post_response url, defaults, options
    end

    #http://apidoc.booker.com/Method/Detail/125
    def get_treatment_categories location_id
      url = build_url "/treatment_categories",
            "?access_token=#{@access_token}&culture_name=&location_id=#{location_id}"
      return_get_response url
    end

    #http://apidoc.booker.com/Method/Detail/126
    def get_treatment_sub_categories location_id, category_id
      url = build_url "/treatment_subcategories",
            "?access_token=#{@access_token}&culture_name=&location_id=#{location_id}&category_id=#{category_id}"
      return_get_response url
    end

    #http://apidoc.booker.com/Method/Detail/153
    def get_location location_id
      url = build_url "/location/#{location_id}", "?access_token=#{@access_token}"
      return_get_response url
    end

    private

      def return_post_response url, defaults, options
        options = defaults.merge(options)
        response = post url, options
        parse_body response.body
      end

      def return_get_response url
        response = get url
        parse_body response.body
      end

      def parse_body body
        body = JSON.parse(body)
        raise Booker::ApiSuccessFalseError if body['IsSuccess'] == false
        body
      end

      def post url, post_data
        options = {
          body: post_data.to_json,
          headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
        }
        HTTParty.post url, options
      end

      def get url
        HTTParty.get url
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

  class ArgumentError < StandardError; end
  class ApiSuccessFalseError < StandardError; end
end
