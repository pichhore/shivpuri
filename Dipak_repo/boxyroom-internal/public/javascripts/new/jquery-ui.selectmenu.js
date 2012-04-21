 /*
 * jQuery UI selectmenu
 *
 * Copyright (c) 2009 AUTHORS.txt (http://jqueryui.com/about)
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * http://docs.jquery.com/UI
 */

(function($) {

$.widget("ui.selectmenu", {
	destroy: function() {
		this.element.removeData(this.widgetName)
			.removeClass(this.widgetBaseClass + '-disabled' + ' ' + this.namespace + '-state-disabled')
			.removeAttr('aria-disabled');
	
		//unbind click on label, reset its for attr
		$('label[for='+this.newelement.attr('id')+']')
			.attr('for',this.element.attr('id'))
			.unbind('click');
		this.newelement.remove();
		this.list.remove();
		this.element.show();	
	},
	_typeAhead: function(code, eventType){
		var self = this;
		//define self._prevChar if needed
		if(!self._prevChar){ self._prevChar = ['',0]; }
		var C = String.fromCharCode(code);
		c = C.toLowerCase();
		var focusFound = false;
		function focusOpt(elem, ind){
			focusFound = true;
			$(elem).trigger(eventType);
			self._prevChar[1] = ind;
		};
		this.list.find('li a').each(function(i){	
			if(!focusFound){
				var thisText = $(this).text();
				if( thisText.indexOf(C) == 0 || thisText.indexOf(c) == 0){
						if(self._prevChar[0] == C){
							if(self._prevChar[1] < i){ focusOpt(this,i); }	
						}
						else{ focusOpt(this,i); }	
				}
			}
		});
		this._prevChar[0] = C;
	},
	_uiHash: function(){
		return {
			value: this.value()
		};
	},
	open: function(event){
		var self = this;
		var disabledStatus = this.newelement.attr("aria-disabled");
		if(disabledStatus != 'true'){
			this._refreshPosition();
			this._closeOthers(event);
			this.newelement
				.addClass('ui-state-active');
			
			this.list
				.appendTo('body')
				.addClass(self.widgetBaseClass + '-open')
				.attr('aria-hidden', false)
				.find('li:not(.'+ self.widgetBaseClass +'-group):eq('+ this._selectedIndex() +') a')[0].focus();	
			if(this.options.style == "dropdown"){ this.newelement.removeClass('ui-corner-all').addClass('ui-corner-top'); }	
			this._refreshPosition();
			this._trigger("open", event, this._uiHash());
		}
	},
	close: function(event, retainFocus){
		if(this.newelement.is('.ui-state-active')){
			this.newelement
				.removeClass('ui-state-active');
			this.list
				.attr('aria-hidden', true)
				.removeClass(this.widgetBaseClass+'-open');
			if(this.options.style == "dropdown"){ this.newelement.removeClass('ui-corner-top').addClass('ui-corner-all'); }
			if(retainFocus){this.newelement[0].focus();}	
			this._trigger("close", event, this._uiHash());
		}
	},
	change: function(event) {
		this.element.trigger('change');
		this._trigger("change", event, this._uiHash());
	},
	select: function(event) {
		this._trigger("select", event, this._uiHash());
	},
	_closeOthers: function(event){
		$('.'+ this.widgetBaseClass +'.ui-state-active').not(this.newelement).each(function(){
			$(this).data('selectelement').selectmenu('close',event);
		});
		$('.'+ this.widgetBaseClass +'.ui-state-hover').trigger('mouseout');
	},
	_toggle: function(event,retainFocus){
		if(this.list.is('.'+ this.widgetBaseClass +'-open')){ this.close(event,retainFocus); }
		else { this.open(event); }
	},
	_formatText: function(text){
		return this.options.format ? this.options.format(text) : text;
	},
	_selectedIndex: function(){
		return this.element[0].selectedIndex;
	},
	_selectedOptionLi: function(){
		return this._optionLis.eq(this._selectedIndex());
	},
	_focusedOptionLi: function(){
		return this.list.find('.'+ this.widgetBaseClass +'-item-focus');
	},
	_moveSelection: function(amt){
		var currIndex = parseInt(this._selectedOptionLi().data('index'), 10);
		var newIndex = currIndex + amt;
		return this._optionLis.eq(newIndex).trigger('mouseup');
	},
	_moveFocus: function(amt){
		if(!isNaN(amt)){
			var currIndex = parseInt(this._focusedOptionLi().data('index'), 10);
			var newIndex = currIndex + amt;
		}
		else { var newIndex = parseInt(this._optionLis.filter(amt).data('index'), 10); }
		
		if(newIndex < 0){ newIndex = 0; }
		if(newIndex > this._optionLis.size()-1){
			newIndex =  this._optionLis.size()-1;
		}
		var activeID = this.widgetBaseClass + '-item-' + Math.round(Math.random() * 1000);
		
		this._focusedOptionLi().find('a:eq(0)').attr('id','');
		this._optionLis.eq(newIndex).find('a:eq(0)').attr('id',activeID)[0].focus();
		this.list.attr('aria-activedescendant', activeID);
	},
	_scrollPage: function(direction){
		var numPerPage = Math.floor(this.list.outerHeight() / this.list.find('li:first').outerHeight());
		numPerPage = (direction == 'up') ? -numPerPage : numPerPage;
		this._moveFocus(numPerPage);
	},
	_setData: function(key, value) {
		this.options[key] = value;
		if (key == 'disabled') {
			this.close();
			this.element
				.add(this.newelement)
				.add(this.list)
					[value ? 'addClass' : 'removeClass'](
						this.widgetBaseClass + '-disabled' + ' ' +
						this.namespace + '-state-disabled')
					.attr("aria-disabled", value);
		}
	},
	value: function(newValue) {
		if (arguments.length) {
			this.element[0].selectedIndex = newValue;
			this._refreshValue();
			this._refreshPosition();
		}
		return this.element[0].selectedIndex;
	},
	_refreshValue: function() {
		var activeClass = (this.options.style == "popup") ? " ui-state-active" : "";
		var activeID = this.widgetBaseClass + '-item-' + Math.round(Math.random() * 1000);
		//deselect previous
		this.list
			.find('.'+ this.widgetBaseClass +'-item-selected')
			.removeClass(this.widgetBaseClass + "-item-selected" + activeClass)
			.find('a')
			.attr('aria-selected', 'false')
			.attr('id', '');
		//select new
		this._selectedOptionLi()
			.addClass(this.widgetBaseClass + "-item-selected"+activeClass)
			.find('a')
			.attr('aria-selected', 'true')
			.attr('id', activeID);
			
		//toggle any class brought in from option
		var currentOptionClasses = this.newelement.data('optionClasses') ? this.newelement.data('optionClasses') : "";
		var newOptionClasses = this._selectedOptionLi().data('optionClasses') ? this._selectedOptionLi().data('optionClasses') : "";
		this.newelement
			.removeClass(currentOptionClasses)
			.data('optionClasses', newOptionClasses)
			.addClass( newOptionClasses )
			.find('.'+this.widgetBaseClass+'-status')
			.html( 
				this._selectedOptionLi()
					.find('a:eq(0)')
					.html() 
			);
			
		this.list.attr('aria-activedescendant', activeID)
	},
	_refreshPosition: function(){	
		//set left value
		this.list.css('left', this.newelement.offset().left);
		
		//set top value
		var menuTop = this.newelement.offset().top;
		var scrolledAmt = this.list[0].scrollTop;
		this.list.find('li:lt('+this._selectedIndex()+')').each(function(){
			scrolledAmt -= $(this).outerHeight();
		});
		
		if(this.newelement.is('.'+this.widgetBaseClass+'-popup')){
			menuTop+=scrolledAmt; 
			this.list.css('top', menuTop); 
		}	
		else { 
			menuTop += this.newelement.height();
			this.list.css('top', menuTop); 
		}
	}
});

$.extend($.ui.selectmenu, {
	getter: "value",
	version: "@VERSION",
	eventPrefix: "selectmenu",
	defaults: {
		transferClasses: true,
		style: 'popup', 
		width: null, 
		menuWidth: null, 
		handleWidth: 26, 
		maxHeight: null,
		icons: null, 
		format: null
	}
});

})(jQuery);