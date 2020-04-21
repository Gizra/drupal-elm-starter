const Page = require('../../page_objects/page');

describe('login page', () => {
    it('should allow the migrated user to authenticate', () => {
        let page = new Page();
        page.login('joe@example.com');
        page.visit('/');
        page.assertDisplayed('body.user-logged-in');
        page.assertNotDisplayed('.messages--error');
        page.assertNotDisplayed('.messages--warning');
    });
});
