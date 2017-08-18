var assert = require('assert');

describe('login page', function() {
    it('should allow a user to login', function() {
        browser.url('/#login');

        browser.waitForVisible('.login-form');
        browser.setValueSafe('[name="username"]', 'admin');
        browser.setValueSafe('[name="password"]', 'admin');
        browser.submitForm('.login-form');
        browser.waitForVisible('.menu h4');
        var title = browser.getText('.menu h4');
        assert.equal(title[1], 'admin');

        // Logout session.
        browser.click('.left.menu > a:nth-child(4)');
        browser.waitForVisible('[name="username"]');
    });

    it('should not allow an anonymous user with wrong credentials to login', function() {
        browser.url('/#login');

        browser.waitForVisible('.login-form');
        browser.setValueSafe('[name="username"]', 'wrong-name');
        browser.setValueSafe('[name="password"]', 'wrong-pass');
        browser.submitForm('.login-form');

        browser.waitForVisible('.login .ui.error.message');
    });
});
