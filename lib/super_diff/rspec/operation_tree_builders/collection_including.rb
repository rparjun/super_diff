module SuperDiff
  module RSpec
    module OperationTreeBuilders
      class CollectionIncluding < SuperDiff::OperationTreeBuilders::Array
        def self.applies_to?(expected, actual)
          SuperDiff::RSpec.a_collection_including_something?(expected) &&
            actual.is_a?(::Array)
        end

        def initialize(expected:, actual:, **rest)
          super

          @expected = actual_with_extra_items_in_expected_at_end
        end

        private

        def actual_with_extra_items_in_expected_at_end
          actual + (expected.expecteds - actual)
        end
      end
    end
  end
end
