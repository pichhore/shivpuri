/**
 * Lightbox overlay management
 */
NL.LightboxController = Class.create();
NL.LightboxController.prototype = {

    loading: function() {
        $$('div.loading').each(function(item) {
                                   item.show();
                               });
    },

    loaded: function() {
        $$('div.loading').each(function(item) {
                                   item.hide();
                               });
	Effect.Appear('overlay_Lightbox', {duration:1, from:0.0, to:-1.8});
	Effect.toggle('lightbox_inv_msg_contents','appear');
    },

    close: function() {
	
	Effect.Fade('overlay_Lightbox',{duration:0});
	Effect.Fade('lightbox_inv_msg_contents',{duration:0});
    },

    initialize: function() {
    }
}