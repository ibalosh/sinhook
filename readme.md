SinHook is a super simple [Sinatra app](http://www.sinatrarb.com/) which was created to simplify in-house webhook testing. 
SinHook will collect JSON based requests and allow debugging them. 

You can easily run the SinHook app locally to inspect and debug webhook requests, without worrying that your webhook requests will end up online.

## Using the app

To use the app, all you need to do is execute the following command:

``` ruby
bundle exec ruby sinhook.rb
```
  
Sinatra web app should be online on your machine at following web address: `http://localhost:8888`.  
Now that the Sinatra web app is online, it is ready to be used. 

You can try it out by generating couple of webhook endpoints.

## Configuration

Once you run the web app for the first time, in config folder, new configuration file called 'general.yaml' will be created.
In this file you can configure things like port to use, number of total hooks to store, whether to use authorization.

## Enable authorization

If you would like to add basic access authentication, all you need to do is enable it in 'security' section in the 'general.yaml' file.
Username and password stored in configuration file will be required once you enable authentication. 

## Endpoints

Here's the list of endpoints and options Sinhook has to offer. 
By accessing these endpoints with tools like CURL, you can manage your list of webhooks, and control behaviour for each one of them.

### POST /hook/generate

Let's you create new webhook endpoint.

Example request with curl:

``` shell 
curl -X POST 'http://localhost:8888/hook/generate'
```

Example response:

``` json
{
    "Message":"New webhook endopint created.",
    "HookUrl":"http://localhost:8888/hook/20bf06f7-aa94-a3ec-89cd-7710f1e1fc83"
}
```

Querystring parameters:

* **name** - allows you to create endpoint with specific name

Example request with curl:

``` shell 
curl -X POST 'http://localhost:8888/hook/generate?name=ibalosh'
```

Example response:

``` json
{
    "Message":"New webhook endopint created.",
    "HookUrl":"http://localhost:8888/hook/ibalosh"
}
```

### POST /hook/{hook_id}

Let's you send a request with data to an endpoint

``` shell 
curl -X POST 'http://localhost:8888/hook/20bf06f7-aa94-a3ec-89cd-7710f1e1fc83 -d {"{'Data':'Hello'}"}'
```

Example response:

``` json
[{"Data":"Hello"}]
``` 

### GET /hook/{hook_id}

Let's you retrieve data from the endpoint.

``` shell 
curl -X GET 'http://localhost:8888/hook/20bf06f7-aa94-a3ec-89cd-7710f1e1fc83'
```

Example response:

``` json
[{"Data":"Hello"}]
``` 

### /DELETE /hook/{hook_id}

Let's you delete a webhook endpoint created before.

Example request with curl:

``` curl
CURL -X DELETE http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8"
``` 

Example response:

``` json
{
    "Message":"Endpoint 20bf06f7-aa94-a3ec-89cd-7710f1e1fc83 deleted."
}
```
 
### /PUT /hook/{hook_id}

Let's you add additional response options to POST/GET /hook/{hook_id} endpoints.
For example, you could set additional response to be a delay in response of 5 seconds.

Querystring parameters:

* **clear** - allows you to clear all data or responses from the endpoint. Possible values: 'data','response', 'data,response'
* **response_status** - allows you to set http status to X number for each next POST/GET request to /hook/{hook_id}
* **response_delay** - allows you to set delayed response for X seconds for each next POST/GET request to /hook/{hook_id}

Example request with curl (sets http response to 500, and delays response for 3 seconds):

``` curl
CURL -X PUT 'http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8?response_status=500&response_delay=3' -d ''"
``` 

Example response:

``` json
{
    "Message":"Status set to 500. Delay set to 3."
}
```

Example request with curl (clears http response to 200, delays, and clears all data from /hook/{hook_id}):

``` curl
CURL -X PUT 'http://localhost:8888/hook/8a85d917-22af-7928-a4e1-148c980b3bc8?clear=data,response&response_status=500&response_delay=3' -d ''"
``` 

Example response:

``` json
{
    "Message":"Cleared data. Cleared response modifications. Status set to 500. Delay set to 3."
}
```

### POST/GET /hook/delay/{seconds}

Sole purpose of this endpoint is to return response after X seconds.

Example request with curl:

``` curl
curl -X GET 'http://localhost:8888/hook/delay/2'
``` 

Example response:

``` json
{
    "Message":"Delayed response for 2 seconds."
}
``` 
 
### POST/GET /hook/status/{code}

Sole purpose of this endpoint is to return http response X.

Example request with curl:

``` curl
curl -X GET 'http://localhost:8888/hook/status/500'
``` 

Example response:

``` json
{
    "Message":"Returned status: 500."
}
``` 

## Notes

The app accepts only valid JSON requests, and make sure that folder where the app is stored is writable for the app.
