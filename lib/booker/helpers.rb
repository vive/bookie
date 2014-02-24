require 'active_support/core_ext/date/zones'

module Booker
  module Helpers
    # Formats a ruby date into the format the Booker wants it in their json API
    def self.format_date time, offset = -5
      return nil unless time

      "/Date(#{(time.in_time_zone(offset)).to_i * 1000})/"
    end
  end
end
