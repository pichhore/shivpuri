/**
 * Model that stores the state of the current tab.
 *
 * Events:
 *
 *  tab.change - notifies observers when the tab has been changed
 *
 */
NL.TabModel = Class.create({
  tab: null,

  change_tab: function(new_tab){
    this.notify("tab.change", this.tab, new_tab);
    this.tab = new_tab;
  },

  current_tab: function(){
    return this.tab;
  },

  initialize: function(starting_tab){
    this.tab = starting_tab;
  }

});
// give the class event notification support
Object.Event.extend(NL.TabModel);

/**
 * Given a root tab element, finds all tab elements and attaches a mouse click observer
 *
 */
NL.TabController = Class.create({

  handleClick: function(ev){
    this.model.change_tab(ev.findElement('li'));
  },

  onTabChange: function(old_tab, new_tab){
    old_tab.removeClassName("active");
    new_tab.addClassName("active");
  },

  //
  // -- Constructor
  //

  initialize: function(starting_tab_index, tab_parent_element){
    if (starting_tab_index == null) {
      starting_tab_index = 1;
    }
    this.li_tabs = tab_parent_element.getElementsBySelector("ul li");
    this.model = new NL.TabModel(this.li_tabs[starting_tab_index - 1]);
    this.li_tabs.each(function(the_tab, index){
      the_tab.setAttribute("tab_index", index + 1);
      the_tab.observe('mousedown', this.handleClick.bindAsEventListener(this));
      the_tab.observe('mouseover', (function(ev){
        ev.findElement('li').addClassName("hover");
      }).bindAsEventListener(this));
      the_tab.observe('mouseout', (function(ev){
        ev.findElement('li').removeClassName("hover");
      }).bindAsEventListener(this));
    }, this);
    this.model.observe("tab.change", this.onTabChange.bind(this));    
  }
});
