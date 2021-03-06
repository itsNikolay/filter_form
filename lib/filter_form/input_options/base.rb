module FilterForm
  module InputOptions
    class Base
      include ActiveModel::Model

      DEFAULT_PREDICATE = nil

      attr_accessor :attribute_name, :object, :custom_predicate, :options

      def simple_form_options
        default_options.merge(additional_options).merge(options)
      end

    private

      def default_options
        {
          required:   false,
          label:      label,
          input_html: additional_input_options.merge(options.delete(:input_html) || {})
        }
      end

      def additional_options
        {}
      end

      def additional_input_options
        result = { name: input_name }

        if input_class
          if options[:input_html]
            result[:class] = (options[:input_html].delete(:class) || '') << " #{ input_class }"
          else
            result[:class] = input_class
          end
        end

        if options[:predicate_selector]
          result.merge!(data: { predicate_selector: options[:predicate_selector] })
        end

        if current_predicate
          result.merge!(data: { current_predicate: current_predicate })
        end

        result
      end

      def label
        if options[:predicate_selector]
          human_attribute_name
        else
          "#{ human_attribute_name } #{ Ransack::Translate.predicate(predicate) }"
        end
      end

      def human_attribute_name
        if association
          association.klass.model_name.human
        else
          object.klass.human_attribute_name(attribute_name)
        end
      end

      def association
        object.klass.reflections[attribute_name]
      end

      def current_predicate
        if object_condition
          object_condition.predicate.name
        elsif options[:predicate_selector]
          predicate
        end
      end

      def input_class
        nil
      end

      def input_name
        "q[#{ input_attribute_name }_#{ predicate }]"
      end

      def input_value
        object_condition.values.first.value if object_condition
      end

      def object_condition
        if options[:predicate_selector]
          object.base.conditions.select { |condition| condition.a.first.name == input_attribute_name.to_s }.first
        else
          object.base.conditions.select do |condition|
            condition.a.first.name == input_attribute_name.to_s && condition.predicate.name == predicate.to_s
          end.first
        end
      end

      def input_attribute_name
        attribute_name
      end

      def predicate
        custom_predicate || self.class::DEFAULT_PREDICATE
      end
    end
  end
end
