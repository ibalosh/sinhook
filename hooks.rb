# encoding: utf-8
require_relative 'hook_storage/folder'
require "sinatra"

module Hooks

  module Response

    class Composite

      def initialize(sinatra)

        @sinatra = sinatra
        @responses = {}
        
      end

      def add_delay(seconds, hook_id)

        clear(hook_id) if @responses[hook_id].nil?
        @responses[hook_id] << Hooks::Response::Delay.new(seconds)

      end

      def add_status(status, hook_id)

        clear(hook_id) if @responses[hook_id].nil?
        @responses[hook_id] << Hooks::Response::Status.new(status)

      end

      def clear(hook_id)

        @responses[hook_id] = []

      end

      def execute(hook_id)

        return if @responses[hook_id].nil?
        @responses[hook_id].each { |response| response.execute(@sinatra) }

      end

    end

    class BaseResponse ; end

    class Delay < BaseResponse

      def initialize(seconds)

        @maximum_delay_seconds = 3600
        @seconds = calculate_delay(seconds)

      end

      def execute(sinatra)

        sleep @seconds

      end

      private

      def calculate_delay(seconds)

        (seconds > 0 && seconds < @maximum_delay_seconds)? seconds : 0

      end

    end

    class Status < BaseResponse

      def initialize(status_code)

        @status_code = status_code

      end

      def execute(sinatra)

        sinatra.status @status_code

      end

    end

  end

  class Data

    def initialize(hooks_to_store_count)

      @hook_storage = HookStorage::Folder.new("#{File.dirname(__FILE__)}/hooks",hooks_to_store_count)

    end

    def hooks_to_store_count

      @hook_storage.hooks_to_store_count

    end

    # create hook
    def create

      @hook_storage.create

    end

    # delete hook
    def delete(hook_id)

      @hook_storage.delete(hook_id)

    end

    # is hook available
    def is_available?(hook_id)

      @hook_storage.is_available?(hook_id)

    end

    #
    # Hook data management
    #

    def set_data(hook_id, hook_data)

      @hook_storage.set_data(hook_id, hook_data)

    end

    def read_data(hook_id)

      @hook_storage.read_data(hook_id)

    end

    def clear_data(hook_id)

      @hook_storage.clear_data(hook_id)

    end

  end

  class DataProxy < Data

    attr_accessor :responses

    def initialize(hooks_to_store_count)

      super(hooks_to_store_count)

    end

    def read_data(hook_id)

      responses.execute(hook_id)
      super(hook_id)

    end

  end

end