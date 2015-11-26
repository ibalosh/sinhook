require_relative 'hooks.rb'
require "sinatra"
require "pry"

class SinHook < Sinatra::Base

  configure do

    set :bind, '0.0.0.0'
    set :hooks_to_store_count, 20
    set :port, 8888
    set :environment, :production

    set :hooks, Hooks.new(settings.hooks_to_store_count)

  end

  # generate id for the webhook
  get "/hook/generate", :provides => :json do

    hook_id = settings.hooks.create
    "{\"hook_id\": \"#{hook_id}\"}"

  end

  post "/hook/generate", :provides => :json do

    hook_id = settings.hooks.create
    "{\"hook_id\": \"#{hook_id}\"}"

  end

  # accept data on specific hook catch url
  post "/hook/:hook_id" do

    if settings.hooks.is_available?(params[:hook_id])

      settings.hooks.set_data(params[:hook_id], request.env["rack.input"].read)

    else

      halt 404, "{\"Error\":\"End point for provided hook id doesn't exists.\"}"

    end

  end

  # get hook data
  get "/hook/:hook_id", :provides => :json do

    if settings.hooks.is_available?(params[:hook_id])

      settings.hooks.read_data(params[:hook_id])

    else

      halt 404, "{\"Error\":\"End point for provided hook id doesn't exists.\"}"

    end

  end

  # get hook data
  get "/hook/http_status/:number" do

    http_code = params[:number].to_i

    if http_code > 200 and http_code < 600

      halt http_code, "{\"Success\":\"Returned status: #{http_code}.\"}"

    else

      halt 404

    end

  end

  # clear hook url data
  delete "/hook/:hook_id" do

    if settings.hooks.is_available?(params[:hook_id]) && settings.hooks.delete(params[:hook_id])

      "{\"Success\":\"End point deleted.\""

    else

      halt 404, "{\"Error\":\"End point for provided hook id doesn't exists.\"}"

    end

  end

  get "/hook/:hook_id/clear", :provides => :json do

    settings.hooks.clear_data(params[:hook_id])
    "{\"Success\":\"List of hooks cleared.\""

  end

  not_found do

    halt 404, "{\"Error\":\"End point not found.\"}"

  end

  error do

    "{\"Error\":\"Ooops, sorry there was a nasty error - #{env['sinatra.error'].name}\"}"

  end

end

SinHook.run!
