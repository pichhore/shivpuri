$(document).ready(function(){
	
	$('.side-search-btn input').hover(
    	function(){
        	$(this).attr({ src : '/imagesside-search-roll.png'});
        },
        function(){
            $(this).attr({ src : '/images/side-search-btn.png'});
        }
    );
    
    $('#home-search-btn input').hover(
    	function(){
        	$(this).attr({ src : '/images/home-search-roll.png'});
        },
        function(){
            $(this).attr({ src : '/images/home-search-btn.png'});
        }
    );
      
});
