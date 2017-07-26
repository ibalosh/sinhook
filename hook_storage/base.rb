require 'guid'

# Interface for storing web hooks
module HookStorage
  class Storage
    attr_accessor :hooks_to_store_count

    def create(_hook_id = nil)
      raise StandardError 'not implemented'
    end

    def delete(_hook_id)
      raise StandardError 'not implemented'
    end

    def is_available?(_hook_id)
      raise StandardError 'not implemented'
    end

    def set_data(_hook_id, _hook_data)
      raise StandardError 'not implemented'
    end

    def read_data(_hook_id)
      raise StandardError 'not implemented'
    end

    def clear_data(_hook_id)
      raise StandardError 'not implemented'
    end

    def endpoints
      raise StandardError 'not implemented'
    end

    protected

    def generate_id
      Guid.new.to_s
    end
  end
end
