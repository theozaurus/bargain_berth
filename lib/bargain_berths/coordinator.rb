module BargainBerths
  class Coordinator

    def initialize(search_params)
      @from       = search_params.fetch(:from)
      @to         = search_params.fetch(:to)
      @date_range = search_params.fetch(:date_range)
    end

    def date_fares
      Hash[date_range.map{|date|
        puts "Downloading #{date}"

        fares = Page.new(search_params_for(date)).fares
        total = Counter.new(fares).total
        puts "Found #{total} bargain berths on #{date}"

        [date, fares]
      }]
    end

    def to_s
      Printer::DateFare.new(date_fares)
    end

    private

    attr_reader :from, :to, :date_range

    def search_params_for(date)
      {:from => from, :to => to, :departure_date => date}
    end

  end
end
