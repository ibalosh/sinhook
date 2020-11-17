require 'fileutils'
require_relative 'base'
require 'redis'

# Storing web hooks to files and hook managing
module HookStorage
  class Redis < Storage
    attr_accessor :redis,
                  :hooks

    def initialize(host, port, hooks_to_store_count)
      @hooks_to_store_count = hooks_to_store_count
      @redis = ::Redis.new(host: host, port: port)
    end

    def create(hook_id = nil)
      hook_id = generate_id if hook_id.nil? || hook_id.empty?
      redis.set(hook_id, [])
      hook_id
    end

    def delete(hook_id)
      redis.del(hook_id)
    end

    def is_available?(hook_id)
      !redis.get(hook_id).nil?
    end

    def set_data(hook_id, hook_data)
      hooks = parsed_hooks(hook_id)
      hooks.shift if hooks.length >= hooks_to_store_count
      hooks << hook_data.force_encoding('utf-8')
      redis.set(hook_id, hooks.to_json)
    end

    def read_data(hook_id)
      parsed_hooks(hook_id).map { |v| parse_data(v) }.to_json
    end

    def clear_data(hook_id)
      redis.set(hook_id, [])
    end

    def endpoints
      redis.keys
    end

    private

    def parsed_hooks(hook_id)
      parse_data(redis.get(hook_id))
    end

    def parse_data(data)
      JSON.parse(data)
    end

  end
end