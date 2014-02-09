require "json"
require "mechanize"

module BargainBerths

  class Page

    attr_reader :from, :to, :departure_date

    def initialize(search_query)
      @from           = search_query.fetch(:from)
      @to             = search_query.fetch(:to)
      @departure_date = search_query.fetch(:departure_date)
    end

    def fares
      begin
        fares_body(true)
      end until fares_body.fetch("complete"){ true }

      return [] if fares_body["status"] == "no fares"

      fares_body.fetch("fares"){
        raise "Could not find fares, got: #{fares_body}"
      }.map{|key,fare| Fare.new fare }
    end

    private

    def fares_body(retry_again=false)
      @fares_body = nil if retry_again
      @fares_body ||= begin
        r = mechanize.get( fares_url )
        puts "Fares body #{r.code}"
        JSON.parse(r.body)
      end
    end

    def homepage_url
      "http://www.scotrail.co.uk/"
    end

    def submitted_form
      homepage.form_with(:name => 'journey'){|f|
        f['ORIGIN_STATION']                       = from
        f['DESTINATION_STATION']                  = to
        f['journey_type_selector']                = "2"
        f['OUTBOUND_DATE']                        = departure_date.strftime("%d/%m/%y")
        f['outbound_arrival_departure_indicator'] = "Leave After"
        f['OUTBOUND_HOUR']                        = "15"
        f['OUTBOUND_MIN']                         = "30"
        f['inbound_arrival_departure_indicator']  = "Leave After"
        f['NUMBER_OF_ADULTS']                     = "1"
        f['NUMBER_OF_CHILDREN']                   = "0"
        f['NUMBER_OF_RAIL_CARDS']                 = "0"
      }.click_button.body
    end

    def fares_url
      ResultPage.new(submitted_form).fares_url
    end

    def homepage
      @homepage ||= begin
        r = mechanize.get(homepage_url)
        puts "Homepage #{r.code}"
        r
      end
    end

    def mechanize
      @mechanize ||= Mechanize.new
    end

  end

end
