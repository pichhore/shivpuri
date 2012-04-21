/**
 * Model that stores the state of a sortable headings.
 *
 * Events:
 *
 *  sortable.change - notifies observers when the sort order has been changed
 *
 */
NL.SortableModel = Class.create({
    sortable: null,
    sortable_mode: "asc",

    change_sortable: function(new_sortable) {
        // if it is new, default to ASC. Otherwise, allow the same sortable to be toggled between ASC to DESC
        if(this.sortable != new_sortable) {
            sortable_mode = "asc";
        } else if(this.sortable_mode == "asc") {
            sortable_mode = "desc";
        } else {
            sortable_mode = "asc";
        }
        this.notify("sortable.change",this.sortable, new_sortable, sortable_mode);
        this.sortable = new_sortable;
        this.sortable_mode = sortable_mode;
    },

    initState: function(sortables) {
        for (var i = 0, length = sortables.length; i < length; i++) {
            sortable = sortables[i];
            has_asc = sortable.hasClassName("asc");
            has_desc = sortable.hasClassName("desc");
            if(has_asc || has_desc) {
                this.sortable = sortable;
                this.sortable_mode = has_asc ? "asc" : "desc";
            }
        }
    },

    toUrlFormat: function() {
        if(this.sortable) {
            return this.sortable.getAttribute("sort")+","+this.sortable_mode;
        }
        return "";
    },

    initialize: function(sortables) {
        this.sortables = sortables;
        this.initState(sortables);
	}

    });
// give the class event notification support
Object.Event.extend(NL.SortableModel);

/**
 * Given a root sortable heading element, finds all sortable elements and attaches a mouse click observer
 *
 */
NL.SortableController = Class.create({


    handleClick: function(event) {
        the_sortable = Event.element(event);
        this.model.change_sortable(the_sortable);
    },

    onSortableChange: function(old_sortable, new_sortable, new_sortable_mode) {
        if(old_sortable) {
            old_sortable.removeClassName("asc");
            old_sortable.removeClassName("desc");
        }
        new_sortable.addClassName(new_sortable_mode);
    },

    attachTo: function(element) {
	       Event.observe(element, 'mousedown', function(event) {
	                 this.handleClick(event);
                      }.bindAsEventListener(this));
	       // element.observe('mousedown', this.handleClick.bindAsEventListener(this));
    },

    attachListeners: function(sortables) {
        this.model.initState(sortables);
        sortables.each(function(item) { this.attachTo(item) }, this);
    },

    //
    // -- Constructor
    //

    initialize: function(sortables) {
        this.model = new NL.SortableModel(sortables);
        //this.model.observe("sortable.change",function(dummy_value, old_sortable, new_sortable, new_sortable_mode) {
        //                       this.onSortableChange(old_sortable, new_sortable, new_sortable_mode);
        //                   }.bindAsEventListener(this));
      this.model.observe('sortable.change', this.onSortableChange.bind(this));
        this.attachListeners(sortables);
    }
    });
