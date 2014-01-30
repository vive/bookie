require 'spec_helper'

describe 'FindLocationsPartial' do
  it 'returns results' do
    client = Booker::Client.new(Auth::KEY, Auth::SECRET)
    locations = client.find_locations_partial
    locations.length.should > 0
    locations.first['ID'].should_not be_nil
  end
end
