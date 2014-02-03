require 'spec_helper'

describe Booker::Client do
  let(:client){ Booker::Client.new(Auth::KEY, Auth::SECRET) }

  describe '#find_locations_partial' do
    it 'is success' do
      response = client.find_locations_partial("PageNumber" => 1, "PageSize" => 5)
      response['IsSuccess'].should be_true
    end
  end

  describe '#find_treatments' do
    before do
      @locations = client.find_locations_partial['Results']
    end

    it 'is success' do
      location = @locations.first
      response = client.find_treatments(
        "LocationID" => location['ID'], "PageNumber" => 1, "PageSize" => 5
      )
      response['IsSuccess'].should be_true
    end
  end

  describe '#run_multi_service_availability' do
    before do
      locations = client.find_locations_partial['Results']
      @location = locations.first
      @treatments = client.find_treatments("LocationID" => @location['ID'])['Treatments']
    end

    it 'is success' do

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
      response['IsSuccess'].should be_true
    end

    it "requires itineraries field" do
      expect {
        client.run_multi_service_availability("LocationID" => @location['ID'])
      }.to raise_error(Booker::ArgumentError)
    end
  end

  describe '#get_treatment_categories' do
    before do
      @locations = client.find_locations_partial['Results']
      @location = @locations.first
    end

    it "is success" do
      response =  client.get_treatment_categories @location['ID']
      response['IsSuccess'].should be_true
    end
  end

  describe '#get_treatment_sub_categories' do
    before do
      locations = client.find_locations_partial['Results']
      @location = locations.first
      @categories = client.get_treatment_categories(@location['ID'])['LookupOptions']
      @category = @categories.first
    end

    it "is success" do
      response =  client.get_treatment_sub_categories @location['ID'], @category['ID']
      response['IsSuccess'].should be_true
    end
  end

  describe '#get_location' do
    before do
      @locations = client.find_locations_partial['Results']
      @location = @locations.first
    end

    it "is success" do
      response =  client.get_location @location['ID']
      p response
      response['IsSuccess'].should be_true
    end
  end

end
