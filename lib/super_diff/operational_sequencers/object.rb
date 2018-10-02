module SuperDiff
  module OperationalSequencers
    class Object < Base
      def initialize(*args)
        super(*args)

        @expected_attributes = attribute_names.reduce({}) do |hash, name|
          hash.merge(name => expected.public_send(name))
        end

        @actual_attributes = attribute_names.reduce({}) do |hash, name|
          hash.merge(name => actual.public_send(name))
        end
      end

      protected

      def unary_operations
        attribute_names.reduce([]) do |operations, name|
          possibly_add_noop_operation_to(operations, name)
          possibly_add_delete_operation_to(operations, name)
          possibly_add_insert_operation_to(operations, name)
          operations
        end
      end

      def operation_sequence_class
        OperationSequences::Object
      end

      def attribute_names
        raise NotImplementedError
      end

      private

      attr_reader :expected_attributes, :actual_attributes

      def possibly_add_noop_operation_to(operations, attribute_name)
        if should_add_noop_operation?(attribute_name)
          operations << Operations::UnaryOperation.new(
            name: :noop,
            collection: actual_attributes,
            key: attribute_name,
            index: attribute_names.index(attribute_name),
            value: actual_attributes[attribute_name],
          )
        end
      end

      def should_add_noop_operation?(attribute_name)
        expected_attributes.include?(attribute_name) &&
          actual_attributes.include?(attribute_name) &&
          expected_attributes[attribute_name] == actual_attributes[attribute_name]
      end

      def possibly_add_delete_operation_to(operations, attribute_name)
        if should_add_delete_operation?(attribute_name)
          operations << Operations::UnaryOperation.new(
            name: :delete,
            collection: expected_attributes,
            key: attribute_name,
            index: attribute_names.index(attribute_name),
            value: expected_attributes[attribute_name],
          )
        end
      end

      def should_add_delete_operation?(attribute_name)
        expected_attributes.include?(attribute_name) && (
          !actual_attributes.include?(attribute_name) ||
          expected_attributes[attribute_name] != actual_attributes[attribute_name]
        )
      end

      def possibly_add_insert_operation_to(operations, attribute_name)
        if should_add_insert_operation?(attribute_name)
          operations << Operations::UnaryOperation.new(
            name: :insert,
            collection: actual_attributes,
            key: attribute_name,
            index: attribute_names.index(attribute_name),
            value: actual_attributes[attribute_name],
          )
        end
      end

      def should_add_insert_operation?(attribute_name)
        !expected_attributes.include?(attribute_name) || (
          actual_attributes.include?(attribute_name) &&
          expected_attributes[attribute_name] != actual_attributes[attribute_name]
        )
      end
    end
  end
end
