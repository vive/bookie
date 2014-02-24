require 'spec_helper'

describe Booker::Helpers do
  describe '#format_date' do
    it 'returns proper response' do
      date = Time.now
      Booker::Helpers.format_date(date).should match(/\A\/Date\(\d+\)\//)
    end
    it 'converts time zones properly' do
      date = Time.now.in_time_zone(-8)
      result = Booker::Helpers.format_date(date, -2)
      result.should_not eq (date.to_i * 1000)
      result.should match(/\A\/Date\(\d+\)\//)
    end

    it 'is nil when no time given' do
      Booker::Helpers.format_date(nil).should be_nil
    end
  end
end

