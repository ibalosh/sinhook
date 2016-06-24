# SinHook

SinHook is a super simple [Sinatra app](http://www.sinatrarb.com/) which was created to simplify in-house web hook testing. 
SinHook will collect JSON based requests and allow debugging them. 

You can easily run the SinHook app locally to inspect and debug web hook requests, without worrying that your web hook requests will end up online.

## Using the app

To use the SinHook application, all you need to do is start up the Sinatra app by executing the following command:

``` ruby
ruby sinhook
```
  
Sinatra web app should be online on your machine at following web address: `localhost:8888`.  
Now that the Sinatra web app is online, it is ready to be used. 

You can try it out by generating couple of web hook endpoints and send requests to them.

## Web hook endpoints

Below, we will show you all the endpoints Sinhook app has to offer. 
By accessing these endpoints by application like CURL, you can manage your web hooks, and control behaviour for each of them.

### Creating endpoint

To create a new web hook request endpoint, visit `http://localhost:8888/hook/generate` URL in your browser. 
Web hook request endpoint will be created, and you will see a hook id for the new endpoint on the page.

This way you have created a unique dedicated endpoint you could use for testing web hooks. You can generate any number of endpoints.

You can also create endpoints with name you would prefer. In that case, visit URL the following way:

`http://localhost:8888/hook/generate?name=ibalosh`
 
 Endpoint with name "ibalosh" will be created.

### Deleting endpoint

To delete new web hook request endpoint, execute following request with tool like CURL.

``` curl
CURL -X DELETE http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8"
``` 

`8a85d917-22af-7928-a4e1-148c980b3bc8` would be the id of the endpoint which you have created before.
 
Web hook request endpoint will be deleted.

### Sending requests to the endpoint

To send a request to an endpoint, send data to `http://localhost:8888/hook/:hook_id` URL. 
Doing this with CURL would look something like this:

``` curl
CURL -X POST http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8 -d "{'Hello World.'}"
``` 

`8a85d917-22af-7928-a4e1-148c980b3bc8` would be the id of the endpoint which you have created before.

### Viewing request responses on the endpoint  

To view web hook requests you sent to an endpoint, all you need to do is visit the web hook endpoint URL, or initiate a GET request.

Web hook URL would look something like:

``` html
http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8"
```

`8a85d917-22af-7928-a4e1-148c980b3bc8` would be the id of the endpoint which you have created before.

When visiting the page, you will see the top last 20 web hooks requests. Older requests are not stored. 
The number of requests stored can be configured in the code configuration.

You can view the web hook endpoint responses also by doing a call like:

``` curl
CURL -X GET http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8
```

### Clear request responses on the endpoint  

When testing, you might have generated bunch of data on your web hook request endpoint. You might want to clear all data on your web hook endpoint.
In order to do that execute the following request.

``` curl
CURL -X GET http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8/clear"
``` 

`8a85d917-22af-7928-a4e1-148c980b3bc8` would be the id of the endpoint which you have created before.

You could do this with visiting the URL too by browser. Once you execute the command, response on that endpoint will be empty.

## HTTP status codes endpoints

Sometimes you need to test whether your web app responds correctly to certain http statuses of web hook endpoints.
In order to test that you could use SinHook app endpoints which return certain http statuses, depending on which one you request.

To try this option out, initiate a GET/PUT/POST request like the following:

``` curl
CURL -X GET http://localhost:8888/hook/status/404"
``` 

This request will return a response with 404 status code.
 
## Delayed response endpoints

Sometimes you need to test whether your web app responds correctly when the response of the endpoint is delayed X seconds.
In order to test that you could use SinHook app endpoints which return response after X seconds.

To try this option out, initiate a GET/PUT/POST request like the following:

``` curl
CURL -X GET http://localhost:8888/hook/delay/3"
``` 

This request will return a response after 3 seconds. 

### Adding response properties to hook endpoints 

Sometimes, you need to create a hook endpoint which will work correctly and return status code 200, but then later on you would want to that endpoint to behave bit differently.
Maybe you would like endpoint to return a response, but with different http status, or with response being delayed.

In order to do something like that all you need to to is do a CURL command like this:

``` curl
CURL -X PUT http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8/status/500"
CURL -X PUT http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8/delay/3"
``` 

* `8a85d917-22af-7928-a4e1-148c980b3bc8` would be the id of the endpoint which you have created before.
* `500` would be the status code `http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8` endpoint will return from now on for GET/POST requests
* `3` would be the seconds delay response `http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8` endpoint will return from now on for GET/POST requests

To clear the added responses to the endpoint, you need to use the following command:

``` curl
CURL -X PUT http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8/clear_responses"
``` 

Once this command is executed, web hook endpoint will work as it did before adding response properties.

## Notes

The app accepts only valid JSON requests, and make sure that folder where the app is stored is writable for the app.
