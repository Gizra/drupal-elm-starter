var elmApp = Elm.Main.fullscreen({
  accessToken: localStorage.getItem('accessToken') || '',
  hostname: window.location.hostname
});

elmApp.ports.accessTokenPort.subscribe(function(accessToken) {
  localStorage.setItem('accessToken', accessToken);
});

Offline.on('down', function() {
  elmApp.ports.offline.send(true);
});

Offline.on('up', function() {
  elmApp.ports.offline.send(false);
});

var pusher = null;

var pusherConfig = null;

elmApp.ports.pusherLogout.subscribe(function () {
  if (pusher) {
    pusher.disconnect();
    pusher = null;
    pusherConfig = null;
  }
});

elmApp.ports.pusherLogin.subscribe(function(config) {
  // If we had a previous connection, disconnect it.
  if (pusher) {
    pusher.disconnect();
  }

  pusherConfig = config;

  pusher = new Pusher(config.key, {
    cluster: config.cluster,
    authEndpoint: config.authEndpoint
  });

  pusher.connection.bind('error', function (error) {
    elmApp.ports.pusherError.send({
      message: error.error.data.message ? error.error.data.message : null,
      code: error.error.code ? error.error.code : null
    });
  });

  pusher.connection.bind('state_change', function (states) {
    elmApp.ports.pusherState.send(states.current);
  });

  if (!pusher.channel(config.channel)) {
    var channel = pusher.subscribe(config.channel);

    config.eventNames.forEach(function(eventName) {
      channel.bind(eventName, function(data) {
        var event = {
          eventType: eventName,
          data: data
        };
        elmApp.ports.pusherItemMessages.send(event);
      });
    });
  }

});
