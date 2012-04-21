/**
 * Generic pagination controller
 */
NL.PaginationController = Class.create();
NL.PaginationController.prototype = {

    handlePaginatePrev: function(event) {
        this.changePage(this.page_number - 1);
        Event.stop(event);
    },

    handlePaginateNext: function(event) {
        this.changePage(this.page_number + 1);
        Event.stop(event);
    },

    changePage: function(to_page_number) {
        if(to_page_number <= this.total_pages && to_page_number > 0) {
            this.page_number = to_page_number;
            this.notify("page.change",to_page_number);
        }
    },

    resetPagination: function() {
        button_bar = $$('div.buttonbar')[0];
        this.page_number = parseInt(button_bar.getAttribute("page_number"));
        this.total_pages = parseInt(button_bar.getAttribute("total_pages"));
        //alert("page_number="+this.page_number+" total_pages="+this.total_pages);
        this.attachListeners();
    },

    attachListeners: function() {
        $$('div.buttonbar a.next_page').each(function(item) {
              Event.observe(item, 'click', function(event) {
                                Event.stop(event);
                                this.handlePaginateNext(event);
                            }.bindAsEventListener(this));
           }.bindAsEventListener(this));
        $$('div.buttonbar a.prev_page').each(function(item) {
              Event.observe(item, 'click', function(event) {
                                Event.stop(event);
                                this.handlePaginatePrev(event);
                            }.bindAsEventListener(this));
           }.bindAsEventListener(this));
    },

    initialize: function() {
        this.resetPagination();
    }
}
// give the class event notification support
Object.Event.extend(NL.PaginationController.prototype);
