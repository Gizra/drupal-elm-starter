var assert = require('assert');

describe('login page', function() {
    it('should allow a user to login', function () {
        browser.url('/#login');
        browser.setValue('[name="username"]', 'admin');
        browser.setValue('[name="password"]', 'admin');
        browser.submitForm('.login-form');
        browser.waitForVisible('.sidebar h4');
        var title = browser.getText('.sidebar h4');
        assert.equal(title, 'admin');

        // Logout session.
        browser.click('.sidebar > a:nth-child(2)');
        browser.waitForVisible('[name="username"]');
    });
});
