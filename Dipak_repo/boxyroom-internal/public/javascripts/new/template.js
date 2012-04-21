$(document).ready(function() {
	
	$("label").inFieldLabels();
	
	$("table.listings .manage").click(function() {
		$(this).children(".menu").fadeIn();
	});
	
	$(document).mouseup(function() {
		$(".menu").fadeOut();
	});
	
	$(".tabs").tabs();
	$(".tabs").fadeIn();
	
	$(".tabs.photos").tabs("rotate", 5000);
	$(".tabs.photos").tabs({ fx: [{opacity:'toggle', duration:'normal'}, {opacity:'toggle', duration:'fast'}] });
	
	$(".tabs.photos .arrows .previous").click(function() {
		var selected = $(".tabs.photos").tabs("option", "selected");
		var max = $(".tabs.photos").tabs("length");
		if (selected == 0) {
			$(".tabs.photos").tabs("select", max - 1);
		} else {
			$(".tabs.photos").tabs("select", selected - 1);
		}
	});
	
	$(".tabs.photos .arrows .next").click(function() {
		var selected = $(".tabs.photos").tabs("option", "selected");
		var max = $(".tabs.photos").tabs("length");
		if (selected == (max - 1)) {
			$(".tabs.photos").tabs("select", 0);
		} else {
			$(".tabs.photos").tabs("select", selected + 1);
		}
	});
	
	$("#property-form").tabs();
	$("#property-form .navigation").appendTo(".secondary");
        //error method resolved
	$("select").selectmenu();
});