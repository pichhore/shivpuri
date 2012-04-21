
//Download by http://down.liehuo.net
     function wcheck () {
        var objCheckbox;
        objCheckbox = $("input[type='checkbox']");
        
        objCheckbox.wrap("<span style='display: inline-block; width: 20px; height: 20px; text-align: left;vertical-align: middle; _overflow: hidden;'></span>");
        objCheckbox.css("filter", "alpha(opacity = 0)");
        objCheckbox.css("opacity", "0");
        objCheckbox.each(function (i) {
            var nchenckbox = $(this);
            var pcheck = $(this).parent();
            pcheck.css("background", "url(images/checkbox.gif)");
            nchenckbox.change(function () {
                checkstate(nchenckbox, pcheck);
            });

            pcheck.mousemove(function () {
                pcheck.css("background-position", "0 40px");
            });

            pcheck.mouseout(function () {
                checkstate(nchenckbox, pcheck);
            });
        });
    }

    function checkstate(nb, pc) {
        if (nb.attr("checked")) {
            pc.css("background-position", "0 20px");
        }
        else {
            pc.css("background-position", "0 0");
        }
    }
    $(document).ready(
            function() {
                wcheck();
            }
        );