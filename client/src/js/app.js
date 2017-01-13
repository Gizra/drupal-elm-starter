var elmApp = Elm.Main.fullscreen({
    accessToken : localStorage.getItem('accessToken') || '',
    hostname : window.location.hostname
});

elmApp.ports.accessTokenPort.subscribe(function(accessToken) {
    localStorage.setItem('accessToken', accessToken);
});


elmApp.ports.pusherConfig.subscribe(function(config) {
  console.log(config);
  var pusher = new Pusher(config.key, {
    cluster: 'eu'
  });

  var channelName = 'general';

  if (!pusher.channel(channelName)) {
      var channel = pusher.subscribe(channelName);

      var eventNames = config.events;

      eventNames.forEach(function(eventName) {
        channel.bind(eventName, function (data) {
            // We wrap the data with some information which will
            // help us dispatch it on the Elm side
            var event = {
                eventType: eventName,
                data: data
            };
            elmApp.ports.pusherItemMessages.send(event);
        });
      });
  }
});

Offline.on('down', function() {
    elmApp.ports.offline.send (true);
});

Offline.on('up', function() {
    elmApp.ports.offline.send (false);
});
