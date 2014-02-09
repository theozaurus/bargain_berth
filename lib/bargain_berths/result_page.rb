module BargainBerths
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
end
