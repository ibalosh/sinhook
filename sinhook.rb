require_relative 'hooks.rb'
require "sinatra"
require "pry"

class SinHook < Sinatra::Base

  class Response

    def initialize

    end

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

    set :hooks, Hooks.new(settings.hooks_to_store_count)
    set :broken_hooks, Hooks::Broken.new
    set :response, Response.new
    set :maximum_hook_delay, 3600

  end

  [:get, :post].each do |method|

    # generate id for the web hook
    send method, "/hook/generate", :provides => :json do

      hook_id = settings.hooks.create
      settings.response.message(:success, "Hook ID: #{hook_id}")

    end

  end

  # accept data on specific hook catch url
  post "/hook/:hook_id" do

    if settings.hooks.is_available?(params[:hook_id])

      settings.hooks.set_data(params[:hook_id], request.env["rack.input"].read)

    else

      halt 404

    end

  end

  # break existing web hook,
  # web hook will return status code :status_code
  put "/hook/:hook_id/break/:status_code" do

    if settings.hooks.is_available?(params[:hook_id])

      settings.broken_hooks.add(params[:hook_id], params[:status_code].to_i)

    end

  end

  # fix broken error web hook,
  # web hook will return status code 200 from now on
  put "/hook/:hook_id/fix" do

    if settings.hooks.is_available?(params[:hook_id])

      settings.broken_hooks.delete(params[:hook_id])

    end

  end

  # get hook data
  get "/hook/:hook_id", :provides => :json do

    hook_id = params[:hook_id]

    if settings.hooks.is_available?(hook_id)

      if settings.broken_hooks.is_available?(hook_id)

        halt settings.broken_hooks.status(hook_id)

      else

        settings.hooks.read_data(hook_id)

      end

    else

      halt 404

    end

  end

  [:get, :post, :put].each do |method|

    send method, "/hook/delayed/:seconds" do

      seconds = params[:seconds].to_i
      seconds = (seconds > 0 && seconds < settings.maximum_hook_delay)? seconds : 0

      sleep seconds
      settings.response.message(:success, "Returned status: 200. Delayed response for #{seconds}")

    end

  end

  [:get, :post, :put].each do |method|

    # get hook data
    send method, "/hook/http_status/:status_code" do

      http_code = params[:status_code].to_i

      if http_code > 200 and http_code < 600

        halt http_code, settings.response.message(:success, "Returned status: #{http_code}.")

      else

        halt 404

      end

    end

  end


  # clear hook url data
  delete "/hook/:hook_id" do

    if settings.hooks.is_available?(params[:hook_id]) && settings.hooks.delete(params[:hook_id])

      settings.response.message(:success, "Endpoint #{params[:hook_id]} deleted.")

    else

      halt 404

    end

  end

  get "/hook/:hook_id/clear", :provides => :json do

    settings.hooks.clear_data(params[:hook_id])
    settings.response.message(:success, "List of hooks cleared.")

  end

  not_found do

    halt 404, settings.response.message(:error, "End point not found.")

  end

  error do

    settings.response.message(:error, "Ooops, sorry there was a nasty error - #{env['sinatra.error'].name}")

  end

end

SinHook.run!
