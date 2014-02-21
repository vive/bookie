module Booker
  module Helpers
    # Formats a ruby date into the format the Booker wants it in their json API
    def self.format_date time
      "/Date(#{time.to_i * 1000})/"
    end
  end
end
