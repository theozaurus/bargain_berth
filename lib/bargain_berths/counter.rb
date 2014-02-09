module BargainBerths
  class Counter

    attr_reader :fares

    def initialize(fares)
      @fares = fares
    end

    def total
      fares.select(&:bargain_berth?).size
    end

  end
end
