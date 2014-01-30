require 'spec_helper'

describe Booker do
  let(:client){ Booker::Client.new(Auth::KEY, Auth::SECRET) }

  describe '#find_locations_partial' do
    it 'returns results' do
      response = client.find_locations_partial("PageNumber" => 1, "PageSize" => 5)
      response['Results'].length.should > 0
    end
  end

  describe '#find_treatments' do
    before do
      @locations = client.find_locations_partial['Results']
    end

    it 'returns results' do
      location = @locations.first
      response = client.find_treatments(
        "LocationID" => location['ID'], "PageNumber" => 1, "PageSize" => 5
      )
      response['Treatments'].length.should > 0
    end
  end

  describe '#run_multi_service_availability' do
    before do
      locations = client.find_locations_partial['Results']
      @location = locations.first
      @treatments = client.find_treatments("LocationID" => @location['ID'])['Treatments']
    end

    it 'returns results' do

      itineraries = @treatments.map do |treatment|
        {
          "IsPackage" => false,
          "Treatments" => [
            {
              "TreatmentID" => treatment['ID']
            }
          ]
        }
      end

      response = client.run_multi_service_availability(
        "LocationID" => @location['ID'],
        "Itineraries" => itineraries
      )
      response['ItineraryTimeSlotsLists'].length.should > 0
    end
  end

end
