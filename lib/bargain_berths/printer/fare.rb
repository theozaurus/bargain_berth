require 'terminal-table'
module BargainBerths
  module Printer
    class Fare
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
  end
end
