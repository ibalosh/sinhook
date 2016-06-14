require_relative 'hooks.rb'
require "sinatra"
require "pry"

class SinHook < Sinatra::Base

  class Response

    def message(type, message)

      "{\"Response\": \"#{STATUS[type]}\",\"Message\": \"#{message}\"}"

    end

    private

    STATUS = {
        :success => 'Success',
        :error => 'Error'
    }

  end

  configure do

    set :bind, '0.0.0.0'
    set :hooks_to_store_count, 20
    set :port, 8888
    set :environment, :production

    set :hooks, Hooks::DataProxy.new(settings.hooks_to_store_count)
    set :response, Response.new

  end

  helpers do

    def hook_exists?(hook_id)

      halt 404 unless settings.hooks.is_available?(hook_id)

    end

    def http_code?(number)

      halt 404 unless number > 200 and number < 600

    end

  end

  # generate id for the web hook, allow using GET method too,
  # so that call can be done through browser, for quick access
  [:get, :post].each do |method|

    send method, "/hook/generate", :provides => :json do

      hook_id = settings.hooks.create
      settings.response.message(:success, "Hook ID: #{hook_id}")

    end

  end

  # delete existing hook and all its data
  delete "/hook/:hook_id" do

    hook_id = params[:hook_id]
    hook_exists?(hook_id)

    if settings.hooks.delete(hook_id)

      settings.response.message(:success, "Endpoint #{hook_id} deleted.")

    else

      settings.response.message(:error, "Could not delete hook with id: #{hook_id}.")

    end

  end

  # accept data on specific hook catch url
  post "/hook/:hook_id" do

    hook_exists?(params[:hook_id])
    settings.hooks.set_data(params[:hook_id], request.env["rack.input"].read)
    settings.hook_actions.execute(hook_id)
    settings.hooks.read_data(hook_id)

  end

  get "/hook/:hook_id", :provides => :json do

    hook_id = params[:hook_id]
    hook_exists?(hook_id)
    settings.hooks.read_data(hook_id)

  end

  # clear all data from an existing hook
  get "/hook/:hook_id/clear", :provides => :json do

    hook_exists?(params[:hook_id])
    settings.hooks.clear_data(params[:hook_id])
    settings.response.message(:success, "List of hooks cleared.")

  end

  # break existing web hook,
  # web hook will return status code :status_code
  put "/hook/:hook_id/status/:status_code" do

    hook_id = params[:hook_id]
    status_code = params[:status_code].to_i
    hook_exists?(hook_id)

    settings.hooks.responses.add_status(status_code, hook_id)
    settings.response.message(:success, "Status code [#{status_code}] set.")

  end

  put "/hook/:hook_id/delay/:seconds" do

    hook_id = params[:hook_id]
    seconds = params[:seconds].to_i
    hook_exists?(hook_id)

    settings.hooks.responses.add_delay(seconds, hook_id)
    settings.response.message(:success, "Delayed response for #{seconds} seconds.")

  end

  # fix broken error web hook,
  # web hook will return status code 200 from now on
  put "/hook/:hook_id/fix" do

    hook_exists?(params[:hook_id])
    settings.hook_actions.clear(params[:hook_id])

  end

  [:get, :post, :put].each do |method|

    send method, "/hook/delay/:seconds" do

      seconds = params[:seconds].to_i
      seconds = (seconds > 0 && seconds < settings.maximum_hook_delay)? seconds : 0

      sleep seconds
      settings.response.message(:success, "Delayed response for #{seconds} seconds.")

    end

  end

  [:get, :post, :put].each do |method|

    # get hook data
    send method, "/hook/status/:status_code" do

      http_code = params[:status_code].to_i
      http_code?(http_code)
      status http_code
      settings.response.message(:success, "Returned status: #{http_code}.")

    end

  end

  not_found do

    halt 404, settings.response.message(:error, "End point not found.")

  end

  error do

    settings.response.message(:error, "Ooops, sorry there was a nasty error - #{env['sinatra.error'].name}")

  end

end

SinHook.run!
