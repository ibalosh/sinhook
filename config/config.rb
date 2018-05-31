require 'yaml'
require 'secure_yaml'
require 'singleton'

# in order to load config files, you need to provide encryption password to the environment
#
# to encrypt content, use the following command:
# encrypt_property_for_yaml encrypt [SECRET_PASSWORD] [CONTENT_TO_ENCRYPT]

module App
  def self.config
    @@config ||= Configurator.new
  end

  class Configurator
    attr_accessor :test_environment,
                  :test_execution

    def load!(name, options = [])
      filename = "#{name}.yaml"
      default_filename = default_filename(filename)

      # Config file can't be loaded, use default.
      begin
        copy_config_file(default_filename, filename) unless config_file_exists?(filename)
      rescue Exception => e
        puts "File #{default_filename} could not be copied to #{filename}. Default filename used. Error details:\n\n #{e}"
        filename = default_filename
      end

      generate_attr_reader name, filter(load_from_yaml(filename), options)
    end

    private

    def filter(data, filters)
      filters = [filters] unless filters.is_a? Array
      result = data
      filters.each { |filter| result = result[filter] }
      result
    end

    def load_from_yaml(filename)
      symbolize_keys SecureYaml.load(File.open(file_full_path(filename)))
    end

    def verify_config_file(filename)
      raise "Configuration file '#{filename}' doesn't exist. Please check your config folder." unless config_file_exists?(filename)
    end

    def copy_config_file(default_filename, filename)
      FileUtils.cp(file_full_path(default_filename), file_full_path(filename))
    end

    def config_file_exists?(filename)
      File.exist? file_full_path(filename)
    end

    def file_full_path(filename)
      File.join(File.dirname(__FILE__), filename)
    end

    def default_filename(filename)
      "#{filename}.default"
    end

    # generate accessors for loaded data
    # accessors will return objects which are deep copy of themselves
    def generate_attr_reader(name, data)
      define_singleton_method(name) do
        Marshal.load(Marshal.dump(data))
      end

      send(name)
    end

    # symbolizes the json string keys, adds an overhead, but its a small config
    def symbolize_keys(json)
      JSON.parse(JSON.dump(json),symbolize_names: true)
    end
  end
end
