Sinhook is a super simple [Sinatra web app](http://www.sinatrarb.com/) which was created to simplify in-house web hook testing.

Back in the days, idea for Sinhook came from the need to replace [Requestb.in](https://github.com/Runscope/requestbin#readme) with something 
that would work locally and would be more reliable. This would make web hook testing safer, provide better performance and tests would be less flacky.

By time, the app was extended with couple of additional features, like testing webhooks behind [basic auth](https://github.com/ibalosh/sinhook/wiki/Configuration), 
[delayed webhook responses](https://github.com/ibalosh/sinhook/wiki/PUT--hook-%7Bhook_id%7D), specific HTTP status responses.
  
The app only requires [Ruby](https://www.ruby-lang.org/en/) to be installed. Web app will preserve your JSON based requests and allow debugging.  

Check out the [wiki page](https://github.com/ibalosh/sinhook/wiki) for more details.

## Demo

Sinhook repository is deployed to [heroku](https://www.heroku.com/). You can play with the app at **https://sinhook.herokuapp.com**.
Check out the features at the [wiki page](https://github.com/ibalosh/sinhook/wiki). 

For example you could create a webhook test endpoint by running:

``` bash
curl -X POST https://sinhook.herokuapp.com/hook/generate
```

## Notes

The app accepts only valid JSON requests. Make sure that folder where the app is stored is writable for the app.
