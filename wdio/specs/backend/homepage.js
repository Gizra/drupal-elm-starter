const Page = require('../../page_objects/page');

describe('homepage', () => {
    it('should not contain any warning or error message', () => {
        let page = new Page();
        page.visit('/');
        page.assertNotDisplayed('.messages--error');
        page.assertNotDisplayed('.messages--warning');
    });
});
