require 'guid'
require_relative 'base'

module HookStorage
  class RAM < Storage
    attr_accessor :hooks_to_store_count,
                  :hooks

    def initialize(hooks_to_store_count)
      @hooks_to_store_count = hooks_to_store_count
      @hooks = {}
    end

    def create(hook_id = nil)
      hook_id = generate_id if hook_id.nil? || hook_id.empty?
      hooks[hook_id] = [] if hooks[hook_id].nil?
      hook_id
    end

    def delete(hook_id)
      hooks.delete hook_id
    end

    def is_available?(hook_id)
      hooks.keys.include? hook_id
    end

    def set_data(hook_id, hook_data)
      hooks[hook_id].shift if hooks[hook_id].length >= hooks_to_store_count
      hooks[hook_id] << hook_data
    end

    def read_data(hook_id)
      hooks[hook_id].to_json
    end

    def clear_data(hook_id)
      hooks[hook_id] = []
    end

    def endpoints
      hooks.keys
    end
  end
end
