require 'active_support/core_ext/date/zones'

module Booker
  module Helpers
    # Formats a ruby date into the format the Booker wants it in their json API
    def self.format_date time, zone = 'Eastern Time (US & Canada)'
      return nil unless time

      "/Date(#{(time.in_time_zone(zone)).to_i * 1000})/"
    end

    # Turn date given by booker api into ruby datetime
    def self.parse_date time
      return nil unless time

      Time.at( time.scan(/\d+/).first.to_i / 1000 ).to_datetime
    end
  end
end
