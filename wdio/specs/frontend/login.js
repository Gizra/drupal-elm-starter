describe('login page', function() {
    it('should allow a user to login', function() {
        browser.frontendLogin('admin');

        // Logout session.
        browser.frontendLogout();
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
