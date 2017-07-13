# encoding: utf-8

require_relative 'hook_storage/folder'
require 'sinatra'

module Hooks
  # Responses class represents a holder which will hold all responses tied to hooks, while server is up and running.
  #
  # It's main function is to hold response types in hash form like: [HOOK_ID][STATUS_TYPE][VALUE]
  # These responses types are picked up by sinatra app and handled
  class Responses
    def initialize
      @responses = {}
    end

    def add(hook_id, type, value)
      clear(hook_id) unless hook_responses_set?(hook_id)
      @responses[hook_id][type] = value
    end

    def clear(hook_id)
      @responses[hook_id] = {}
    end

    def get(hook_id)
      hook_responses_set?(hook_id) ? @responses[hook_id] : {}
    end

    def hook_responses_set?(hook_id)
      !@responses[hook_id].nil?
    end
  end

  # Delegation class for different web hook data holders.
  # Currently only one type of web hook data holders is available - Folder storage - which holds all data
  # for web hooks locally, in folders and files.
  class Data
    def initialize(hooks_to_store_count)
      @hook_storage = HookStorage::Folder.new("#{File.dirname(__FILE__)}/hooks", hooks_to_store_count)
    end

    def hooks_to_store_count
      @hook_storage.hooks_to_store_count
    end

    def create(hook_id = nil)
      @hook_storage.create(hook_id)
    end

    def delete(hook_id)
      @hook_storage.delete(hook_id)
    end

    def is_available?(hook_id)
      @hook_storage.is_available?(hook_id)
    end

    # Hook data management
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
end
