# encoding: utf-8
require_relative 'hook_storage/folder'

class Hooks

  attr_accessor :hooks_to_store_count

  def initialize(hooks_to_store_count)

    @hooks_to_store_count = hooks_to_store_count
    @hook_storage = HookStorage::Folder.new("#{File.dirname(__FILE__)}/hooks",hooks_to_store_count)

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