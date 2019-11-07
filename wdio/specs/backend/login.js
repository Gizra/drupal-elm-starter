describe('login page', function() {
    it('should allow a user to login', function() {
        browser.login('admin');

        // Logout session.
        browser.logout();
    });

    it('should not allow an anonymous user with wrong credentials to login', function() {
        browser.url('/user/login');

        browser.waitForVisible('#user-login');
        browser.setValueSafe('[name="name"]', 'wrong-name');
        browser.setValueSafe('[name="pass"]', 'wrong-pass');
        browser.submitForm('#user-login');

        browser.waitForVisible('.messages.error');
    });
});
