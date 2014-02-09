require 'terminal-table'
module BargainBerths
  module Printer
    class DateFare

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
  end
end
