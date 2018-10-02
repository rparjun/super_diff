module SuperDiff
  module DiffFormatters
    class Hash < Base
      def self.applies_to?(operations)
        operations.is_a?(OperationSequences::Hash)
      end

      def call
        Collection.call(
          open_token: "{",
          close_token: "}",
          collection_prefix: collection_prefix,
          build_item_prefix: -> (operation) {
            key =
              if operation.respond_to?(:left_key)
                operation.left_key
              else
                operation.key
              end

            if key.is_a?(Symbol)
              "#{key}: "
            else
              "#{key.inspect} => "
            end
          },
          operations: operations,
          indent_level: indent_level,
          add_comma: add_comma?,
        )
      end
    end
  end
end
