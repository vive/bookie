require 'httparty'
require 'booker/helpers'
require 'booker/version'
require 'logger'
module Booker
  STAGING_BASE_HOST = "apicurrent-app.booker.ninja"
  PRODUCTION_BASE_HOST = "app.secure-booker.com"
  BASE_PATH = "/WebService4/json/customerService.svc"

  class Client
    attr_reader :url, :access_token, :expires_in, :server_time_offset
    def logger
      @logger ||= Logger.new STDOUT
    end

    def logger=logger
      @logger = logger
    end

    def initialize(key, secret, options = {})
      @production = options.fetch(:production) { false }
      @log_level = options.fetch(:log_level) { Logger::DEBUG }
      @key = key
      @secret = secret
      set_log_level!
      set_access_token!
      set_server_time_offset!
    end

    # Useful to pull all of paged results and return them as if you did one
    # request for them all
    #
    # ex: client.all(:find_locations, 'Results')
    def all method, result_name, options = {}
      page_number = 1
      results = []

      # this allows page size to be overidden but NOT page_number as I want to
      # control that to know when we have all results
      options = {"PageSize" => 500}.merge options

      begin
        options.merge!({
          "PageNumber" => page_number,
        })

        last_result = self.send(method, options)

        results << last_result[result_name]
        results.flatten!


        if last_result['TotalResultsCount']
          total_results  = last_result['TotalResultsCount']
        else
          total_results = 0
        end
        logger.debug "#{results.length} / #{total_results}"
        page_number+=1
      end while results.length < total_results-1

      last_result.merge({
        result_name => results
      })
    end

    def run_service_availability options = {}, pass_response = false
      url = build_url '/availability/service'
      defaults = {
        "EndDateTime" => Time.now.to_i + 60 * 60 * 5,
        "LocationID" => 3749,
        "MaxTimesPerTreatment" => 5,
        "StartDateTime" => Time.now,
        "TreatmentCategoryID" => 1,
        "TreatmentSubCategoryID" => 218,
        "access_token" => @access_token
      }
      convert_time_to_booker_format! options
      if pass_response
        request_params url, defaults, options
      else
        return_post_response url, defaults, options
      end
    end

    #http://apidoc.booker.com/Method/Detail/129
    def run_multi_service_availability options = {}, pass_response = false
      raise Booker::ArgumentError, 'Itineraries is required' unless options['Itineraries']
      url = build_url "/availability/multiservice"
      defaults =
        {
        "access_token" => @access_token,
        "StartDateTime" => Time.now,
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
        "EndDateTime" => Time.now.to_i + 60 * 60 * 5,
      }
      convert_time_to_booker_format! options
      if pass_response
        request_params url, defaults, options
      else
        return_post_response url, defaults, options
      end
    end

    def run_multi_spa_availability options = {}, pass_response = false
      # TODO: Assert required fields are present
      url = build_url '/availability/multispa'
      defaults = {
        #"AirportCode" => "",
        #"BrandID" => null,
        #"CityName" => "New York City",
        #"CountryCode" => "USA",
        #"IsApiDistributionPartner" => null,
        #"Latitude" => null,
        #"Longitude" => null,
        "Radius" => 20,
        #"SpaExistsInSpaFinder" => null,
        #"StateAbbr" => "NY",
        "ZipCode" => "77057",
        "MaxNumberOfLocations" => 5,
        "EndDateTime" => Time.now.to_i + 60 * 60 * 5,
        #"LocationID" => 3749,
        #"MaxTimesPerTreatment" => 2,
        "StartDateTime" => Time.now.to_i,
        "TreatmentCategoryID" => 30,
        "TreatmentSubCategoryID" => 218,
        "access_token" => @access_token
      }
      convert_time_to_booker_format! options
      if pass_response
        request_params url, defaults, options
      else
        return_post_response url, defaults, options
      end
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
        "PageSize" => 100,
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

    # http://apidoc.booker.com/Method/Detail/852
    def find_locations options = {}
      url = build_url "/locations"
      defaults = {
        "access_token" => @access_token,
        "BrandID" => nil,
        "BusinessName" => nil,
        "FeatureLevel" => nil,
        "PageNumber" => 1,
        "PageSize" => 5,
        "SortBy" => [
          {
            "SortBy" => "Name",
            "SortDirection" => 0
          }
        ],
        "UsePaging" => true, # throws a weird exception about null arguments
      }
      return_post_response url, defaults, options
    end

    def find_employees options = {}
      url = build_url '/employees'

      defaults = {
        "IgnoreFreelancers" => true,
        "LocationID" => nil,
        "OnlyIncludeActiveEmployees" => true,
        "PageNumber" => 1,
        "PageSize" => 10,
        "SortBy" => [
          {
            "SortBy" => "LastName",
            "SortDirection" => 0
          }
        ],
        "TreatmentID" => nil,
        "UsePaging" => true,
        "access_token" => @access_token
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

    def create_appointment options = {}
      url = build_url "/appointment/create"
      defaults = {
        "access_token" => @access_token,
      }
      convert_time_to_booker_format! options
      return_post_response url, defaults, options
    end
  
    def cancel_appointment options = {}
      raise Booker::ArgumentError, 'ID is required' unless options['ID']
      url = build_url "/appointment/cancel"
      defaults = {
        "access_token" => @access_token,
      }
      return_put_response url, defaults, options
    end
 
     def get_appointment appointment_id
       url = build_url "/appointment/#{appointment_id}", "?access_token=#{@access_token}"
       return_get_response url
     end
  
    def create_customer options = {}
      url = build_url "/customer"

      defaults = {
        'FirstName' => '',
        'LastName' => '',
        'HomePhone' => '',
        'LocationID' => '',
        'Email' => '',
        "access_token" => @access_token,
      }

      return_post_response url, defaults, Booker::Helpers.new_client_params(options)
    end

    #http://apidoc.booker.com/Method/Detail/124
    def get_treatment treatment_id
      url = build_url "/treatment/#{treatment_id}", "?access_token=#{@access_token}"
      return_get_response url
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

    #http://apidoc.booker.com/Method/Detail/134
    def get_location_online_booking_settings location_id
      url = build_url "/location/#{location_id}/online_booking_settings",
              "?access_token=#{@access_token}"
      return_get_response url
    end

    #http://apidoc.booker.com/Method/Detail/107
    def get_credit_card_types location_id
      url = build_url "/location/#{location_id}/creditcard_types",
              "?access_token=#{@access_token}"
      return_get_response url
    end

    #http://apidoc.booker.com/Method/Detail/147
    def get_server_information
      url = build_url "/server_information", "?access_token=#{@access_token}"
      return_get_response url
    end

    private
      def return_post_response url, defaults, options
        options = defaults.merge(options)
        log_options options
        response = post url, options
        parse_body response.body
      end

      def request_params url, defaults, options
        options = defaults.merge(options)
        {
          url: url,
          options: options
        }
      end

      def return_put_response url, defaults, options
        options = defaults.merge(options)
        log_options options
        response = put url, options
        parse_body response.body
      end  

      def return_get_response url
        response = get url
        parse_body response.body
      end

      def parse_body body
        body = JSON.parse(body)
        raise Booker::ApiSuccessFalseError, body if body['IsSuccess'] == false
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

      def put url, put_data
        options = {
          body: put_data.to_json,
          headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
        }
        HTTParty.put url, options
      end

      def set_log_level!
        logger.level = @log_level
      end

      def set_access_token!
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

      def set_server_time_offset!
        @server_time_offset = get_server_information['ServerTimeZoneOffset']
      end


      def base_url
        "https://" + (@production ? Booker::PRODUCTION_BASE_HOST : Booker::STAGING_BASE_HOST) + Booker::BASE_PATH
      end

      def build_url path, query = ''
        base_url + path + query
      end

      def convert_time_to_booker_format! options
        options['StartDateTime'] = Booker::Helpers.format_date options['StartDateTime'], server_time_offset
        options['EndDateTime'] = Booker::Helpers.format_date options['EndDateTime'], server_time_offset

        if options['ItineraryTimeSlotList']
          options['ItineraryTimeSlotList'].each do |time_slot_list|

            time_slot_list['StartDateTime'] = Booker::Helpers.format_date time_slot_list['StartDateTime'], server_time_offset

            time_slot_list['TreatmentTimeSlots'].each do |time_slot|
              time_slot['StartDateTime'] = Booker::Helpers.format_date time_slot['StartDateTime'], server_time_offset
            end
          end

        end
      end

      def log_options options
        msg = "-----------------------\n"
        msg << "Ruby-Booker Options:\n"
        msg << "#{options}"
        msg << "\n-----------------------"
        logger.debug msg
      end
  end

  class ArgumentError < StandardError; end
  class ApiSuccessFalseError < StandardError; end
end
