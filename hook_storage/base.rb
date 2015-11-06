require "guid"

module HookStorage

  # interface for hook storage
  class Storage

    attr_accessor :hooks_to_store_count

    def create

      raise StandardError 'not implemented'

    end

    def delete(hook_id)

      raise StandardError 'not implemented'

    end

    def is_available?(hook_id)

      raise StandardError 'not implemented'

    end

    def set_data(hook_id, hook_data)

      raise StandardError 'not implemented'

    end

    def read_data(hook_id)

      raise StandardError 'not implemented'

    end

    def clear_data(hook_id)

      raise StandardError 'not implemented'

    end

    protected

    def generate_id

      Guid.new.to_s

    end

  end

end