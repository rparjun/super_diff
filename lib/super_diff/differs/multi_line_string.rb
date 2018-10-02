module SuperDiff
  module Differs
    class MultiLineString < Base
      def self.applies_to?(value)
        value.is_a?(::String) && value.include?("\n")
      end

      def call
        DiffFormatters::MultiLineString.call(
          operations,
          indent_level: indent_level,
        )
      end

      private

      def operations
        OperationalSequencers::MultiLineString.call(
          expected: expected,
          actual: actual,
          extra_operational_sequencer_classes: extra_operational_sequencer_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes,
        )
      end
    end
  end
end
