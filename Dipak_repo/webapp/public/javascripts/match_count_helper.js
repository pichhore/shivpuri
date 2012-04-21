/**
 * Updates any elements that are of class match_count with the values provided by the server (tabs, screen stats, etc)
 */
NL.MatchCountHelper = Class.create();
NL.MatchCountHelper.prototype = {

    updateCounts: function(count_all, count_new, count_favorites, count_viewed_me, count_messages) {
        this.updateCountForEach($$('span.match_count[result_filter=all]'),count_all);
        this.updateCountForEach($$('span.match_count[result_filter=new]'),count_new);
        this.updateCountForEach($$('span.match_count[result_filter=favorites]'),count_favorites);
        this.updateCountForEach($$('span.match_count[result_filter=viewed_me]'),count_viewed_me);
        this.updateCountForEach($$('span.match_count[result_filter=messages]'),count_messages);
    },

    updateCountForEach: function(items, new_value) {
        for (var i = 0, length = items.length; i < length; i++) {
            items[i].update(new_value);
        }
    },

    initialize: function() {
    }
}
