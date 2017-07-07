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
    cluster: 'eu',
    authEndpoint: config.authEndpoint
  });

  pusher.connection.bind('error', function (err) {
    elmApp.ports.pusherError.send({
      message: err.data.message,
      code: err.data.code,
      when: Date.now()
    });
  });

  pusher.connection.bind('state_change', function (states) {
    elmApp.ports.pusherState.send(states.current);
  });

  pusher.connection.bind('connecting_in', function (delay) {
    elmApp.ports.pusherConnectingIn.send(delay);
  });
});

elmApp.ports.subscribeToPrivateChannel.subscribe(function (params) {
  if (!pusher) {
    console.log ('Tried to subscribe to private pusher channel before login.');
    return;
  }

  var channelName = 'private-general';

  if (!pusher.channel(channelName)) {
    var channel = pusher.subscribe(channelName);
  }
});

elmApp.ports.unsubscribeFromPrivateChannel.subscribe(function (sessionId) {
  if (!pusher) return;

  pusher.unsubscribe('private-general');
});
