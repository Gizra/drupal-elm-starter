# Drupal Elm Starter

[![Build Status](https://travis-ci.org/Gizra/drupal-elm-starter.svg?branch=master)](https://travis-ci.org/Gizra/drupal-elm-starter)

Drupal Elm Starter is a starter kit for setting up sites using Drupal as a backend and [Elm](http://elm-lang.org/) in the frontend.

For the backend, check the [server README.md](https://github.com/Gizra/drupal-elm-starter/blob/master/server/README.md)

For the frontend, check the [client README.md](https://github.com/Gizra/drupal-elm-starter/blob/master/client/README.md)

## Pusher
When the item will be updated (E.g. via the backend on 
[/node/1/edit](http://localhost/drupal-elm-starter/server/www/node/1/edit)), 
it will fire Pusher messages that will update the Elm application in real time.

Editing an item produces pusher messages on two different channels: `general` 
and `private-general`. The private channel is only accessible by users with 
`access private fields` permission, and currently exposes the item's "Private 
note" field, which normal users can't access. 

Log in to the Elm app for example with `admin` / `admin` to see also the item
private note field (on [/#/item/1](http://localhost:3000/#/item/1) for 
example), and get notifications through the private channel.
Log in with a normal user (For exmaple `alice` / `alice`), to get notifications
through the public pusher channel.
 
## Credits

[Gizra](https://gizra.com)

## License

MIT
