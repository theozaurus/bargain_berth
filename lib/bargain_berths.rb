#!/usr/bin/env ruby
require "rubygems"
require "mechanize"
require "json"
require "irb"

class Coordinator

  def initialize(search_params={})
    @from       = search_params.fetch(:from)
    @to         = search_params.fetch(:to)
    @date_range = search_params.fetch(:date_range)
  end

  def date_fares
    Hash[date_range.map{|date|
      puts "Downloading #{date}"

      fares = Page.new(search_params_for(date)).fares
      total = BargainBerthCounter.new(fares).total
      puts "Found #{total} bargain berths on #{date}"

      [date, fares]
    }]
  end

  def to_s
    BargainBerthPrinter.new(date_fares)
  end

  private

  attr_reader :from, :to, :date_range

  def search_params_for(date)
    {:from => from, :to => to, :departure_date => date}
  end

end

class Page

  attr_reader :from, :to, :departure_date

  def initialize(search_query={})
    @from           = search_params.fetch(:from)
    @to             = search_params.fetch(:to)
    @departure_date = search_params.fetch(:departure_date)
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

class ResultPage

  def initialize(body)
    @body = body
    @time = Time.now
  end

  def fares_url
    "http://tickets.scotrail.co.uk/sr/en/JourneyPlanning/CheckForFTAEnquiryCompletion.aspx?cnt=1&id0=#{enquiry_id}&resend=Y&date=#{date}&sess=#{session_id}"
  end

  private
  attr_reader :body, :time

  def session_id
    r = body.match(/mixingDeck.sessionId *= *'([a-z0-9]*)'/)
    r ? r[1] : raise("Could not find session_id in: #{body}")
  end

  def enquiry_id
    r = body.match(/mixingDeck.enquiryIds *= *\[ *([0-9]*)\]/)
    r ? r[1] : raise("Could not find enquiry_id in: #{body}")
  end

  def date
    time.to_i * 1000
  end
end

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

require 'terminal-table'
class ResultPrinter

  attr_reader :fares

  def initialize(fares)
    @fares = fares
  end

  def to_s
    Terminal::Table.new(:headings => headings, :rows => rows).to_s
  end

  def headings
    ['Description', 'TT Code', 'Total Fare', 'Sleeper Type']
  end

  def rows
    sorted_fares.map{|f| [f.description, f.tt_code, f.total_fare, f.sleeper_type] }
  end

  def sorted_fares
    fares.sort_by{|f| f.total_fare }
  end

end

class BargainBerthPrinter

  attr_reader :date_fares

  def initialize(date_fares)
    @date_fares = date_fares
  end

  def to_s
    Terminal::Table.new(:headings => headings, :rows => rows).to_s
  end

  def headings
    ['Date', 'Total bargain berths']
  end

  def rows
    date_fares.map{|date,fares| [date, BargainBerthCounter.new(fares).total] }
  end

end

class BargainBerthCounter

  attr_reader :fares

  def initialize(fares)
    @fares = fares
  end

  def total
    fares.select(&:bargain_berth?).size
  end

end


require "pp"
IRB.start

