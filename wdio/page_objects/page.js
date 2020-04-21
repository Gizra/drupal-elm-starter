class Page {

    /**
     * Page constructor.
     *
     * @param {String} domain
     * @param {Object} browser
     */
	constructor(domain = '', browser = null) {
        this._domain = domain;
        this._browser = browser;
        this._current_user = null;
    }

    /**
     * Returns a browser object.
     */
    get browser() {
        if (this._browser) {
            return this._browser;
        }
        return browser;
    }

    /**
     * Returns a domain to use as base of the requests.
     */
    get domain() {
        return this._domain;
    }

    /**
     * Set the base domain where request should be made.
     *
     * @param {String} domain
     */
    setDomain(domain) {
        this._domain = domain;
    }

    /**
     * Set the browser to use to make the requests.
     *
     * @param {object} browser
     */
    setBrowser(browser) {
        this._browser = browser;
    }

    /**
     * Visits a page using a specific domain.
     *
     * @param {String} path
     */
	visit(path) {
        this.browser.url(this.domain + path);
    }

    /**
     * Writes text into a Wysiwyg widget.
     *
     * @param {String} fieldname
     *   The wysiwyg field name. Usually the selector without the #.
     * @param {String} text
     *   The text to insert into the wysiwyg.
     */
    setWysiwygValue(fieldname, text) {
        this.browser.execute('CKEDITOR.instances["' + fieldname + '"].insertText("' + text + '");');
    }

    /**
     * Defines a datapicker value.
     *
     * @param {String} fieldname
     *   Usually the selector without the #.
     * @param {String} date
     *   A date value formated with YYYY-MM-DD.
     */
    setDateValue(fieldname, date) {
        this.browser.execute('document.getElementById("' + fieldname + '").value = "' + date + '";');
    }

    /**
      * Recursive function to ensure event dispatch on option select.
      *
      * This command makes sure that when selecting an option to trigger any event
      * that is supposed to be triggered, this is because the normal
      * "SelectByValue" and "Click" commands do select an option but it doesn't
      * dispatch any event attached to the select list.
      *
      * @param {String} option
      *   The option to be selected.
      */
    setSelectValue(selector, visibleText) {
        this.browser.$(selector).selectByVisibleText(visibleText);
    }

    /**
     * Starts a session with a specific user and password.
     *
     * @param {String} user
     * @param {String} password
     */
    login(user, password = '1234') {
        if (this._current_user == user) {
            return;
        }
        // Force a logout to avoid potential already logged in users.
        this.logout();
        this.visit('/user/login');
        this.assertDisplayed('#user-login-form', 4500);
        this.setValue('#edit-name', user);
        this.setValue('#edit-pass', password);
        this.click('#user-login-form #edit-submit');
        this.assertExist('body.user-logged-in', 5000);
        this._current_user = user;
    }

    /**
     * Logouts the current logged in user.
     */
    logout() {
        this._current_user = null;
        this.visit('/user/logout');
    }

    static randomString(length = 7) {
        return Math.random().toString(36).substring(length);
    }

    setValue(selector, value) {
        this.browser.$(selector).setValue(value);
    }

    click(selector) {
        this.browser.$(selector).click();
    }

    /**
     * Returns an array of text strings that are displayed as breadcrumbs.
     */
    getBreadcrumb() {
        return this.browser.$('#breadcrumb ol li').value
        .map(item => item.getText());
    }

    assertNotDisplayed(selector, timeout = 1000) {
        this.browser.$(selector).waitForDisplayed(timeout, true);
    }

    assertDisplayed(selector, timeout = 1000) {
        this.browser.$(selector).waitForDisplayed(timeout);
    }

    assertExist(selector, timeout = 1000) {
        this.browser.$(selector).waitForExist(timeout);
    }

    assertNotExist(selector, timeout = 1000) {
        this.browser.$(selector).waitForExist(timeout, true);
    }
}

module.exports = Page;