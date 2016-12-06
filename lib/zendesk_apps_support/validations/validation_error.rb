# frozen_string_literal: true
require 'json'

module ZendeskAppsSupport
  module Validations
    class ValidationError < StandardError
      KEY_PREFIX = 'txt.apps.admin.error.app_build.'

      class DeserializationError < StandardError
        def initialize(serialized)
          super "Cannot deserialize ValidationError from #{serialized}"
        end
      end

      class << self
        # Turn a JSON string into a ValidationError.
        def from_json(json)
          hash = JSON.load(json)
          raise DeserializationError, json unless hash.is_a?(Hash)
          from_hash(hash)
        rescue JSON::ParserError, NameError
          raise DeserializationError, json
        end

        def from_hash(hash)
          raise DeserializationError, hash unless hash['class']
          klass = constantize(hash['class'])
          raise DeserializationError, hash unless klass <= self
          klass.vivify(hash)
        end

        # Turn a Hash into a ValidationError. Used within from_json.
        def vivify(hash)
          new(hash['key'], hash['data'])
        end

        private

        def constantize(klass)
          klass.to_s.split('::').inject(Object) { |klass, part| klass.const_get(part) }
        end
      end

      attr_reader :key, :data

      def initialize(key, data = nil)
        @key = key
        @data = symbolize_keys(data || {})
      end

      def to_s
        ZendeskAppsSupport::I18n.t("#{KEY_PREFIX}#{key}", data)
      end

      def to_json(*)
        JSON.generate(as_json)
      end

      def as_json(*)
        {
          'class' => self.class.to_s,
          'key'   => key,
          'data'  => data
        }
      end

      private

      def symbolize_keys(hash)
        hash.each_with_object({}) do |(key, value), result|
          result[key.to_sym] = value
          result
        end
      end
    end

    class JSHintValidationError < ValidationError
      attr_reader :filename, :jshint_errors

      def self.vivify(hash)
        new(hash['filename'], hash['jshint_errors'])
      end

      def initialize(filename, jshint_errors)
        errors = jshint_errors.compact.map { |err| "\n  L#{err['line']}: #{err['reason']}" }.join('')
        @filename = filename, @jshint_errors = jshint_errors
        super(:jshint, {
          file: filename,
          errors: errors,
          count: jshint_errors.length
        })
      end

      def as_json(*)
        {
          'class' => self.class.to_s,
          'filename' => filename,
          'jshint_errors' => jshint_errors
        }
      end
    end
  end
end
