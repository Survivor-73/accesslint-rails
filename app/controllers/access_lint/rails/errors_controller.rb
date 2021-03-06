require "warning"

module AccessLint
  module Rails
    class ErrorsController < ApplicationController
      skip_before_action :verify_authenticity_token, only: :create

      def create
        warnings.each do |warning|
          logger.tagged("AccessLint") do
            logger.warn(warning.message)
          end
        end

        head :ok
      end

      private

      def warnings
        violations_params.map do |violation|
          Warning.new(url, violation)
        end
      end

      def violations_params
        accesslint_params.fetch(:violations)
      end

      def accesslint_params
        params.require(:accesslint)
      end

      def url
        URI.parse(accesslint_params.fetch(:url))
      end

      def logger
        @logger ||= ActiveSupport::TaggedLogging.new(::Rails.logger)
      end
    end
  end
end
