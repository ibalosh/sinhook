require 'fileutils'
require_relative 'base'

module HookStorage

  # storing web hooks to files and hook managing
  class Folder < Storage


    attr_accessor :root_folder,
                  :filename

    ROOT_FOLDER = 'hooks'
    FILENAME = 'hook'

    def initialize(folder, hooks_to_store_count)

      @hooks_to_store_count = hooks_to_store_count
      @root_folder = folder
      @filename = FILENAME

    end

    def create

      hook_id = generate_id

      create_folder(root_folder)
      create_folder(hook_folder(hook_id))
      hook_id

    end

    def delete(hook_id)

      begin

        FileUtils.rm_rf("#{hook_folder(hook_id)}")
        true

      rescue

        false

      end

    end

    def set_data(hook_id, hook_data)

      create_folder(root_folder)

      File.open(hook_filename(hook_id), "w") { |f| f.puts hook_data }
      remove_old_hooks(hook_id)
      read_data(hook_id)

    end

    def read_data(hook_id)

      "[" + hook_folder_files(hook_id).map { |file| File.read(file).strip }.join(",") + "]"

    end

    def clear_data(hook_id)

      remove_all_hooks(hook_id)

    end

    def is_available?(hook_id)

      File.directory? hook_folder(hook_id)

    end

    private

    def create_folder(folder)

      Dir.mkdir folder unless File.directory?(folder)

    end

    def hook_folder(hook_id)

      "#{root_folder}/#{hook_id}"

    end

    def hook_filename(hook_id_folder)

      "#{root_folder}/#{hook_id_folder}/#{filename}#{generate_id}"

    end

    # hook folder files with newest ones at top
    def hook_folder_files(hook_id)

      Dir["#{hook_folder(hook_id)}/*"].sort_by { |f| File.mtime(f) }.reverse

    end

    def remove_old_hooks(hook_id_folder)

      remove_hooks(hook_id_folder, hooks_to_store_count)

    end

    def remove_all_hooks(hook_id_folder)

      remove_hooks(hook_id_folder, 0)

    end

    def remove_hooks(hook_id, index_after)

      files = hook_folder_files(hook_id)
      (index_after..files.size-1).each { |i| File.delete files[i] }

    end

  end

end