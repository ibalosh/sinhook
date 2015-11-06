# SinHook

SinHook is a super simple [Sinatra app](http://www.sinatrarb.com/) which will collect JSON based requests made to it. 
You can easily run it locally to inspect and debug webhook requests, without worrying that your webhook requests will end up online.

# Using the app

All you need to do is start up the Sinatra app by executing command

``` ruby
ruby sinhook
```
  
Sinatra webapp should be online on your `localhost:8888` address.  
Now that the Sinatra webapp is online, it is ready to be used. 

You can try it out by generating couple of webhook endpoints and send requests to them.

# Creating web hook requests endpoint

To create a new webhook request endpoint, visit `http://localhost:8888/hook/generate` URL in your browser. 
Webhook request endpoint is created, and you will see a hook id for the new endpoint on the page.

# Sending requests to webhook endpoint

To send requests to newly created endpoint, send data to `http://localhost:8888/hook/:hook_id` URL. 
Doing this with CURL would look something like this:

``` curl
CURL -X POST http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8 -d "{'Hello World.'}"
``` 

# Viewing the requests on webhook endpoint  

To view webhook requests you sent to an endpoint, all you need to do is visit the webhook endpoint URL, or initiate a GET request.

Webhook URL would look something like:

``` html
http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8"
```

In the URL, after `/hook/` the hook_id is placed. 

When visiting the page, you will see the top last 20 webhooks requests. Older requests are not sored.


# Notes

The app accepts only valid JSON requests, and make sure that folder where the app is stored is writable for the app.
