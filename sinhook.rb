require_relative 'hooks.rb'
require_relative 'config/config'
require 'sinatra'
require 'pry'
require 'json'

class SinHook < Sinatra::Base

  # load configuration file
  def self.config
    App.config.load!(:general)
    App.config.general
  end

  if config[:security][:basic_auth]
    use Rack::Auth::Basic, "Restricted Area" do |username, password|
      username == config[:security][:username] and password == config[:security][:password]
    end
  end

  # Configuration settings for the app.
  configure do
    set :bind, '0.0.0.0'
    set :hooks_to_store_count,  config[:hooks_to_store]
    set :hooks_storage,         config[:hooks_storage].to_sym
    set :port,                  config[:port]
    set :environment, :production

    set :hooks, Hooks::Data.new(settings.hooks_to_store_count, settings.hooks_storage)
    set :hooks_responses, Hooks::Responses.new
  end

  # Helpers which allow easy management of webhooks.
  module HooksHelper
    RESPONSE_TYPES = %i[status delay message].freeze
    MAXIMUM_SECONDS_DELAY = 3600

    def hooks
      settings.hooks
    end

    def hooks_responses
      settings.hooks_responses
    end

    def hook_found?(hook_id)
      halt 404 unless settings.hooks.is_available?(hook_id)
    end

    def valid_http_code?(number)
      number >= 200 && number <= 600
    end

    def seconds_delay(seconds)
      seconds > 0 && seconds < MAXIMUM_SECONDS_DELAY ? seconds : 0
    end

    def response_message(data)
      if data.is_a?(Hash)
        data.to_json
      else
        response = {}
        response['Message'] = data
        response.to_json
      end
    end

    def response_status(value)
      valid_http_code?(value) ? status(value) : status(500)
    end

    def response_delay(value)
      sleep value
    end

    def execute_responses(hook_id)
      settings.hooks_responses.get(hook_id).each {|key, value| send("response_#{key}", value)}
    end
  end

  helpers HooksHelper

  # ENDPOINTS:

  # Generate new webhook endpoint.
  # Default or with name passed by parameter 'name'
  post '/hook/generate', provides: :json do
    hook_id = params[:name]

    if hooks.is_available?(hook_id)
      response_status(405)
      response_message("Web hook with id: #{hook_id} already exists.")
    elsif hook_id.eql?('list')
      response_status(405)
      response_message("#{hook_id} is a reserved word.")
    else
      hook_id = settings.hooks.create(hook_id)
      response_message({
                           'Message' => 'New webhook endopint created.',
                           'HookUrl' => "#{url.match(/(.*)\/generate/)[1]}/#{hook_id}",
                       })
    end
  end

  # Accept data on specific webhook endpoint.
  post '/hook/:hook_id' do
    hook_id = params[:hook_id]
    hook_found?(hook_id)

    execute_responses(hook_id)
    hooks.set_data(hook_id, request.env['rack.input'].read)
    hooks.read_data(hook_id)
  end

  # Delete existing webhook endpoint.
  delete '/hook/:hook_id' do
    hook_id = params[:hook_id]
    hook_found?(hook_id)

    if hooks.delete(hook_id)
      response_message("Endpoint #{hook_id} deleted.")
    else
      response_status(500)
      response_message("Could not delete hook with id: #{hook_id}.")
    end
  end

  get '/hook/list', provides: :json do
    hooks.endpoints.map { |e| "#{url.match(/(.*)\/list/)[1]}/#{e}" }.to_json
  end

  # Read specific webhook endpoint response.
  get '/hook/:hook_id', provides: :json do
    hook_id = params[:hook_id]
    hook_found?(hook_id)
    execute_responses(hook_id)
    hooks.read_data(hook_id)
  end

  # Update webhook endpoint, so that post/get /hook/:endpoint return modified response
  # Optional modification parameters:
  #
  # ?response_status=500 (any valid http number)
  # ?response_delay=5 (seconds, any valid number)
  # ?clear=data
  # ?clear=responses
  # ?clear=data,responses
  put '/hook/:hook_id' do
    hook_id = params[:hook_id]
    hook_found?(hook_id)
    message = []

    # Clear all webhook data.
    if params[:clear].to_s.include? 'data'
      hooks.clear_data(params[:hook_id])
      message << 'Cleared data.'
    end

    # Clear all webhook response modifications, like delayed response.
    if params[:clear].to_s.include? 'response'
      hooks_responses.clear(hook_id)
      message << 'Cleared response modifications.'
    end

    responses = {}
    responses[:status] = params[:response_status].to_i
    responses[:delay] = params[:response_delay].to_i

    responses.each do |type, response|
      unless response == 0
        hooks_responses.add(hook_id, type, response)
        message << "#{type.to_s.capitalize} set to #{response}."
      end
    end

    response_message(message.join(' '))
  end

  # Webhook endpoint with sole purpose to return response after :seconds seconds
  %i[get post put].each do |method|
    send method, '/hook/delay/:seconds' do
      seconds = seconds_delay(params[:seconds].to_i)
      response_delay(seconds)
      response_message("Delayed response for #{seconds} seconds.")
    end
  end

  # Webhook endpoint with sole purpose to return response with :status_code status
  %i[get post put].each do |method|
    # get hook data
    send method, '/hook/status/:status_code' do
      http_code = params[:status_code].to_i
      response_status(http_code)
      response_message("Returned status: #{http_code}.")
    end
  end

  get '/robots.txt', provides: :text do
    "User-agent: *\nDisallow: /"
  end

  # GENERAL ENDPOINTS:
  not_found do
    halt 404, response_message('End point not found.')
  end

  error do
    response_message("Ooops, sorry there was a nasty error - #{env['sinatra.error'].name}.")
  end
end

SinHook.run!
