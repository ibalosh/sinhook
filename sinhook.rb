require_relative 'hooks.rb'
require "sinatra"
require "pry"

class SinHook < Sinatra::Base

  configure do

    set :bind, '0.0.0.0'
    set :hooks_to_store_count, 20
    set :port, 8888
    set :environment, :production

    set :hooks, Hooks::Data.new(settings.hooks_to_store_count)
    set :hooks_responses, Hooks::Responses.new

  end

  helpers do

    STATUS = {
        :success => 'Success',
        :error => 'Error'
    }

    MAXIMUM_SECONDS_DELAY = 3600

    def response_message(type, message)

      "{\"Response\": \"#{STATUS[type]}\",\"Message\": \"#{message}\"}"

    end

    def hook_exists?(hook_id)

      halt 404 unless settings.hooks.is_available?(hook_id)

    end

    def http_code?(number)

      number > 200 and number < 600

    end

    def seconds_delay(seconds)

      (seconds > 0 && seconds < MAXIMUM_SECONDS_DELAY)? seconds : 0

    end

    def response_status(value)

      http_code?(value)? status(value) : status(500)

    end

    def response_delay(value)

      sleep value

    end

    def get_responses(hook_id)

      settings.hooks_responses.get(hook_id).each { |key,value| send("response_#{key.to_s}",value) }

    end

  end

  # generate id for the web hook, allow using GET method too,
  # so that call can be done through browser, for quick access
  [:get, :post].each do |method|

    send method, "/hook/generate", :provides => :json do

      hook_id = settings.hooks.create
      response_message(:success, "Hook ID: #{hook_id}")

    end

  end

  # delete existing hook and all its data
  delete "/hook/:hook_id" do

    hook_id = params[:hook_id]
    hook_exists?(hook_id)

    if settings.hooks.delete(hook_id)

      response_message(:success, "Endpoint #{hook_id} deleted.")

    else

      status 500
      response_message(:error, "Could not delete hook with id: #{hook_id}.")

    end

  end

  # accept data on specific hook catch url
  post "/hook/:hook_id" do

    hook_exists?(params[:hook_id])
    settings.hooks.set_data(params[:hook_id], request.env["rack.input"].read)
    settings.hooks.read_data(params[:hook_id])

  end

  get "/hook/:hook_id", :provides => :json do

    hook_id = params[:hook_id]
    hook_exists?(params[:hook_id])
    get_responses(hook_id)
    settings.hooks.read_data(params[:hook_id])

  end

  [:get, :post].each do |method|

    # clear all data from an existing hook
    send method, "/hook/:hook_id/clear", :provides => :json do

      hook_exists?(params[:hook_id])
      settings.hooks.clear_data(params[:hook_id])
      response_message(:success, "List of hooks cleared.")

    end

  end

  # break existing web hook,
  # web hook will return status code :status_code
  put "/hook/:hook_id/status/:status_code" do

    hook_id = params[:hook_id]
    status_code = params[:status_code].to_i
    hook_exists?(hook_id)

    settings.hooks_responses.add(hook_id, :status, status_code)
    response_message(:success, "Status code [#{status_code}] set.")

  end

  put "/hook/:hook_id/delay/:seconds" do

    hook_id = params[:hook_id]
    seconds = seconds_delay(params[:seconds].to_i)
    hook_exists?(hook_id)

    settings.hooks_responses.add(hook_id, :delay, seconds)
    response_message(:success, "Delayed response for #{seconds} seconds.")

  end

  # fix broken error web hook,
  # web hook will return status code 200 from now on
  put "/hook/:hook_id/fix" do

    hook_exists?(params[:hook_id])
    settings.hook_actions.clear(params[:hook_id])

  end

  [:get, :post, :put].each do |method|

    send method, "/hook/delay/:seconds" do

      seconds = seconds_delay(params[:seconds].to_i)
      response_delay(seconds)
      response_message(:success, "Delayed response for #{seconds} seconds.")

    end

  end

  [:get, :post, :put].each do |method|

    # get hook data
    send method, "/hook/status/:status_code" do

      http_code = params[:status_code].to_i
      response_status(http_code)
      response_message(:success, "Returned status: #{http_code}.")

    end

  end

  not_found do

    halt 404, response_message(:error, "End point not found.")

  end

  error do

    response_message(:error, "Ooops, sorry there was a nasty error - #{env['sinatra.error'].name}")

  end

end

SinHook.run!