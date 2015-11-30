# SinHook

SinHook is a super simple [Sinatra app](http://www.sinatrarb.com/) which was created to simplify in-house webhook testing. 
SinHook will collect JSON based requests and allow debugging them. 

You can easily run the SinHook app locally to inspect and debug webhook requests, without worrying that your webhook requests will end up online.

## Using the app

To use the SinHook application, all you need to do is start up the Sinatra app by executing the following command:

``` ruby
ruby sinhook
```
  
Sinatra webapp should be online on your machine at following web address: `localhost:8888`.  
Now that the Sinatra webapp is online, it is ready to be used. 

You can try it out by generating couple of webhook endpoints and send requests to them.

## Webhook endpoints

### Creating endpoint

To create a new webhook request endpoint, visit `http://localhost:8888/hook/generate` URL in your browser. 
Webhook request endpoint will be created, and you will see a hook id for the new endpoint on the page.

This way you have created a unique dedicated endpoint you could use for testing webhooks. You can generate any number of endpoints.

### Sending requests to the endpoint

To send a request to an endpoint, send data to `http://localhost:8888/hook/:hook_id` URL. 
Doing this with CURL would look something like this:

``` curl
CURL -X POST http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8 -d "{'Hello World.'}"
``` 

`8a85d917-22af-7928-a4e1-148c980b3bc8` would be the id of the endpoint which you have created before.

### Viewing requests on the endpoint  

To view webhook requests you sent to an endpoint, all you need to do is visit the webhook endpoint URL, or initiate a GET request.

Webhook URL would look something like:

``` html
http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8"
```

`8a85d917-22af-7928-a4e1-148c980b3bc8` would be the id of the endpoint which you have created before.

When visiting the page, you will see the top last 20 webhooks requests. Older requests are not sored.

### Breaking hook endpoint with specific status code

Sometimes, you need to create a hook endpoint which will work correctly and return status code 200, but then later on you want to break
it to return status code 500 to test behaviour when endpoint breaks. In order to do that all you need to to is do a CURL command like this:

``` curl
CURL -X PUT http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8/break/500"
``` 

* `8a85d917-22af-7928-a4e1-148c980b3bc8` would be the id of the endpoint which you have created before.
* `500` would be the status code it will return from now on

To fix the endpoint, you need to use the following command:

``` curl
CURL -X PUT http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8/fix"
``` 

## HTTP status codes endpoints

Sometimes you need to test whether your webapp responds correctly to certain http statuses of webhook endpoints.
In order to test that you could use SinHook app endpoints which return certain http statuses, depending on which one you request.

To try this option out, initiate a GET request like the following:

``` curl
CURL -X GET http://localhost:8888/hook/http_status/404"
``` 

This request will return a response with 404 status code. 

## Notes

The app accepts only valid JSON requests, and make sure that folder where the app is stored is writable for the app.
