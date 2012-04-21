/*
 * You must not remove the following information:
 * YUI Lightbox Beta
 * From TheCodeCentral.com
 * 8/17/2007
 *
 * For installation instruction, bug report and feature suggestion, 
 * please visit http://thecodecentral.com/2007/08/17/yui-based-lightbox-revisit
 *
 * Licensed under the Creative Commons Attribution-ShareAlike License, Version 3.0 (the "License")
 * You may obtain a copy of the License at
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

YAHOO.namespace('com.thecodecentral');

var $E = YAHOO.util.Event;
// Prototype already defines this -> var $  = YAHOO.util.Dom.get;
var $D = YAHOO.util.Dom;


YAHOO.com.thecodecentral.Lightbox = function(conf){
	this.conf = conf == null ? {} : conf;
	this._init();
	this._initLoader();
	this._initLightbox();
	this._loadData();
};

YAHOO.com.thecodecentral.Lightbox.prototype._init = function(){
	$D.addClass(document.body, 'yui-skin-sam');
};

YAHOO.com.thecodecentral.Lightbox.prototype._loadData = function(){
	var r = this.conf.dataSource;
	
	var timers = {};
	
	for(var i in r){
		timers[i] = null;
		
		var onMouseOut = function(e, o) {
			if (! timers[o.imgId]) return;
			clearTimeout(timers[o.imgId]);
			timers[o.imgId] = null;
			o.self.lightboxLoader.hide();
			o.self.showImgPanel.hide();
		}
		
		var onMouseOver = function(e, o){
			
			if (timers[o.imgId]) return;
			o.self.lightboxLoader.show();
			
			
			timers[o.imgId] = setTimeout(function() {
				$D.setStyle(o.imgId, 'cursor', 'auto');
				var onImageLoad = function(e, o){
					o.self.lightboxLoader.hide();
					var title;
					if(o.self.conf.dataSource[o.imgId].title == null || 
					o.self.conf.dataSource[o.imgId].title.length == 0){
						title = '&nbsp;';
					}else{
						title = o.self.conf.dataSource[o.imgId].title;
					}
					o.self.showImgPanel.setHeader(title);
					o.self.showImgPanel.show();
					o.self._autoFit(o.image);
				};
				while(o.self._imgHolder.firstChild){
					o.self._imgHolder.removeChild(o.self._imgHolder.firstChild);
				}
				var image = document.createElement('img');
				o.self._imgHolder.appendChild(image);
				$E.on(image, 'load', onImageLoad, {self:o.self, image: image, imgId: o.imgId});
				o.self.lightboxLoader.show();
				image.src = r[o.imgId].url;
			}, 500);
		};
		var imgSmall = $(i);
		$E.on(imgSmall, 'mouseover', onMouseOver, {self: this, imgId: i});
		$E.on(imgSmall, 'mouseout', onMouseOut, {self: this, imgId: i});
		$D.setStyle(imgSmall, 'cursor', 'pointer');
	}
};

YAHOO.com.thecodecentral.Lightbox.prototype._autoFit = function(image){
	var iw = image.width ;
	var ih = image.height;
	var vw = $D.getViewportWidth() - 50;
	var vh = $D.getViewportHeight() - 70;
	//resize image
	if(iw >= 250 || ih >= 250){
		if(iw > vw || ih > vh){
			var ratioi = iw/ih;
			var ratiow = vw/vh;
			if(ratioi <= ratiow){
				image.height = vh;
				image.width = iw * (vh / ih);
			}else{
				image.width = vw;
				image.height = ih * (vw / iw);
			}
		}
		// Dwellgo - start at 500 or less
		if (image.width > 500 || image.height > 500) {
			var pct = 500/Math.max(image.width, image.height);
			image.height = image.height * pct;
			image.width = image.width * pct;
		}
		this.showImgPanel.cfg.setProperty('width', (image.width + 20)  + 'px');
	}else{
		this.showImgPanel.cfg.setProperty('width', '250px');
	}
	this.showImgPanel.center();
	if ($('image3')) {
	 this.showImgPanel.cfg.setProperty('x', $D.getX('image3')+75);
	}
};

YAHOO.com.thecodecentral.Lightbox.prototype._initLoader = function(){
	var lightboxLoader = new YAHOO.widget.Panel('tcc_lightboxLoader',{
		width:"240px",
		fixedcenter:true,
		close:false,
		draggable:false,
		modal:false,
		visible:false
	});
	lightboxLoader.setHeader("Loading, please wait...");
	var progressBar = document.createElement('img');
	progressBar.src = this.conf.imageBase + '/progressBar.gif';
	lightboxLoader.setBody(progressBar);
	lightboxLoader.render(document.body);

	this.lightboxLoader = lightboxLoader;
};

YAHOO.com.thecodecentral.Lightbox.prototype._initLightbox = function(){
	var showImgPanel = new YAHOO.widget.Panel('tcc_showImgPanel',
	{
		width: '200px',
		visible : false,
		draggable:true,
		modal:false,
		close:false
	});

	var imgHolder = document.createElement('div');
	imgHolder.id = 'tcc_showImgPanelImgHolder';
	$D.setStyle(imgHolder, 'text-align', 'center');
	showImgPanel.setBody(imgHolder);
	showImgPanel.setHeader('&nbsp;');
	showImgPanel.render(document.body);
	var showImgPanelCloseHandler = function(e, o){
		o.hide();
	};
	/*
	$E.on(showImgPanel.body, 'click', showImgPanelCloseHandler, showImgPanel);
	$D.setStyle(showImgPanel.body, 'cursor', 'pointer');
	var showImgPanelMoveHandler = function(e, o){
		this.sizeMask();
	};
	showImgPanel.moveEvent.subscribe(showImgPanelMoveHandler);

	//add maximum button
	var showImgPanelElem = $('tcc_showImgPanel');
	var resizeBtnCon = document.createElement('div');
	resizeBtnCon.id = 'tcc_showImgPanelResizeBtnCon';
	$D.setStyle(resizeBtnCon, 'position', 'absolute');
	$D.setStyle(resizeBtnCon, 'right', '35px');
	$D.setStyle(resizeBtnCon, 'top', '5px');

	showImgPanelElem.appendChild(resizeBtnCon);
	* 
	//create maximum/restore bttons
	var btnMaximum = document.createElement('img');
	btnMaximum.src = this.conf.imageBase + '/maximum.gif';

	var btnRestore = document.createElement('img');
	btnRestore.src = this.conf.imageBase + '/restore.gif';

	this._resizeBtnCon = resizeBtnCon;
	this._btnRestore = btnRestore;
	this._btnMaximum = btnMaximum;
	*/
	this._imgHolder = imgHolder;
	this.showImgPanel = showImgPanel;
};

YAHOO.com.thecodecentral.Lightbox.prototype._setResizeButton = function(type){
	while(this._resizeBtnCon.firstChild){
		this._resizeBtnCon.removeChild(this._resizeBtnCon.firstChild);
	}
	if(type == 'maximum'){
		this._resizeBtnCon.appendChild(this._btnMaximum);
	}else{
		this._resizeBtnCon.appendChild(this._btnRestore);
	}
};
