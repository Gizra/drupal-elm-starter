var assert = require('assert');

describe('home', function() {
    it('should allow a user to login', function() {
        browser.url('/');

        browser.waitForVisible('.login-form');
    });
});
