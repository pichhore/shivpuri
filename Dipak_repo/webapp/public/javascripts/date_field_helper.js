/**
 * Converts a currency input field into comma-separated currency after a field loses focus
 */
NL.DateFieldHelper = Class.create();
NL.DateFieldHelper.prototype = {

    handleFocusLost: function(event) {
        the_element = Event.element(event);		
        result = the_element.value;
		regex = "^(([1-9])|(0[1-9])|(1[0-2]))[\/-](([0-9])|([0-2][0-9])|(3[0-1]))[\/-](([0-9][0-9])|([1-2][0,9][0-9][0-9]))$"
        alert(result);
        if(result.match(regex) != null) {
            the_element.value = result;
        } else {
			alert("Oops! "+result+" does not appear to be a valid date.  Please try again.");
			the_element.focus();
			Event.stop(event);
        }
    },

    commaSplit: function(srcNumber) {
        var txtNumber = '' + srcNumber.replace(/,/g,"");
        if (isNaN(txtNumber) && txtNumber != "") {
            alert("Oops! "+txtNumber+" does not appear to be a valid number.  Please try again.");
            return null;
        }
        else {
            var rxSplit = new RegExp('([0-9])([0-9][0-9][0-9][,.])');
            var arrNumber = txtNumber.split('.');
            arrNumber[0] += '.';
            do {
                arrNumber[0] = arrNumber[0].replace(rxSplit, '$1,$2');
            } while (rxSplit.test(arrNumber[0]));
            if (arrNumber.length > 1) {
                return arrNumber.join('');
            }
            else {
                return arrNumber[0].split('.')[0];
            }
        }
    },

    initialize: function(field_element) {
        this.field_element = field_element
        Event.observe(field_element, 'blur', function(event) {
                          this.handleFocusLost(event);
                      }.bindAsEventListener(this));
    }

}
