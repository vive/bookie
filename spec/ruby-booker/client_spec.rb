require 'spec_helper'

describe Booker::Client do
  let(:client){ Booker::Client.new(Auth::PROD_KEY, Auth::PROD_SECRET) }
  #let(:client){ Booker::Client.new(Auth::KEY, Auth::SECRET) }

  def it_should_be_success response
    response['IsSuccess'].should be_true
  end

  describe '#find_locations' do
    it 'is success' do
      response = client.find_locations
      it_should_be_success response
    end
  end

  describe '#find_locations_partial' do
    it 'is success' do
      response = client.find_locations_partial
      it_should_be_success response
    end
  end

  describe '#all' do
    it 'is success' do
      response = client.all(:find_locations, 'Results')
      it_should_be_success response
    end
  end

  describe '#run_multi_spa_availability' do
    it 'is success' do
      response = client.run_multi_spa_availability(
        "StartDateTime" => Time.now,
        "EndDateTime" => Time.now + 5.hours,
        "TreatmentCategoryID" => 29,
        "TreatmentSubCategoryID" => 170,
        "MaxNumberOfLocations" => 2
      )
      it_should_be_success response
    end
  end

  context 'requires locations' do
    before do
      @locations = client.find_locations_partial['Results']
      @location = @locations.first
    end

    describe '#find_treatments' do

      it 'is success' do
        response = client.find_treatments(
          "LocationID" => @location['ID'], "PageNumber" => 1, "PageSize" => 5
        )
        it_should_be_success response
      end
    end

    context 'requires treatments' do
      before do
        @treatments = client.find_treatments("LocationID" => @location['ID'])['Treatments']
      end

      describe '#run_service_availability' do
        it 'is success' do
          response = client.run_service_availability(
            "LocationID" => @location['ID'],
            "StartDateTime" => Time.now,
            "EndDateTime" => Time.now + 5.hours,
            "TreatmentCategoryID" => 29,
            "TreatmentSubCategoryID" => 170
          )
          it_should_be_success response
        end
      end

      describe '#run_multi_service_availability' do
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
            "Itineraries" => itineraries,
            "StartDateTime" => Time.now,
            "EndDateTime" => Time.now + 5.hours,
          )
          it_should_be_success response
        end

        it "requires itineraries field" do
          expect {
            client.run_multi_service_availability("LocationID" => @location['ID'])
          }.to raise_error(Booker::ArgumentError)
        end
      end
    end

    describe '#get_treatment_categories' do
      it "is success" do
        response =  client.get_treatment_categories @location['ID']
        it_should_be_success response
      end
    end

    describe '#get_treatment_sub_categories' do
      before do
        @categories = client.get_treatment_categories(@location['ID'])['LookupOptions']
        @category = @categories.first
      end

      it "is success" do
        response =  client.get_treatment_sub_categories @location['ID'], @category['ID']
        it_should_be_success response
      end
    end

    describe '#get_location' do
      it "is success" do
        response =  client.get_location @location['ID']
        it_should_be_success response
      end
    end

    describe '#get_location_online_booking_settings' do
      it "is success" do
        response =  client.get_location_online_booking_settings @location['ID']
        it_should_be_success response
      end
    end

    describe '#get_credit_card_types' do
      it "is success" do
        response =  client.get_credit_card_types @location['ID']
        it_should_be_success response
      end
    end
  end

  describe '#get_server_information' do
    it 'is success' do
      response = client.get_server_information
      it_should_be_success response
    end
  end

  describe '#create_appointment' do
    it 'is success' do
      pending 'TODO: pass this test. Since the api call doesn\'t have a consistent available time, I need to somehow catch the error '
      time = Time.now + 2.hours
      response = client.create_appointment(
        {
          "ItineraryTimeSlotList" => [
            {
              "StartDateTime" => time,
              "TreatmentTimeSlots" => [
                {
                  "StartDateTime" => time,
                  "TreatmentID" => 565636
                }
              ]
            }
          ],
          "AppointmentPayment" =>  {
            "PaymentItem" => {
              "CreditCard" => {
                "BillingZip" => "77057",
                "ExpirationDate" => "/Date(1371441600000)/",
                "NameOnCard" => "John Doe",
                "Number" => "4111111111111111",
                "SecurityCode" => "123",
                "Type" => {
                  "ID" => 2,
                  "Name" => "Visa"
                }
              },
              "Method" => {
                "ID" => 1,
                "Name" => "Credit Card"
              }
            }
          },
          "Customer" => {
            "LastName" => "Craige",
            "FirstName" => "Jake",
            "Email" => "example@example.com",
            "HomePhone" => "1234567890"
          },
          "LocationID" => 11543
        }
      )
    end
  end

end
