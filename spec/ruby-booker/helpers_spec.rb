require 'spec_helper'

describe Booker::Helpers do
  describe '#format_date' do
    it 'returns proper response' do
      date = Time.now
      Booker::Helpers.format_date(date).should match(/\A\/Date\(\d+\)\//)
    end
  end
end

