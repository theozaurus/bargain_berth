module BargainBerths
  class Fare

    attr_reader :description, :tt_code, :sleeper_type, :adult_fare, :total_adult_fare, :total_fare

    def initialize(opts)
      @adult_fare       = opts.fetch("adultFare")     # 12780,
      @description      = opts.fetch("desc")     # "Caledonian Sleeper Flexipass",
      @first_class      = opts.fetch("fClass")     # "1",
      @is_discounted    = opts.fetch("isDiscounted")     # false,
      @sleeper_type     = opts.fetch("sleeperType")     # "_",
      @total_adult_fare = opts.fetch("totAdultFare")     # 127800,
      @total_fare       = opts.fetch("totFare")     # 127800,
      @tt_code          = opts.fetch("ttCode")     # "FP5",
    end

    def first_class?
      @first_class == "1"
    end

    def discounted?
      @is_discounted
    end

    def bargain_berth?
      description == "Bargain Berth"
    end

  end
end
