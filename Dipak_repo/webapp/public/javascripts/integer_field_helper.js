/**
 * Forces a text input to only allow numbers
 */
NL.IntegerFieldHelper = Class.create();
NL.IntegerFieldHelper.prototype = {

    handleFocusLost: function(event) {
        the_element = Event.element(event);
        result = this.commaSplit(the_element.value);
        if(result != null) {
            the_element.value = result;
        } else {
            Event.stop(event);
            the_element.focus();
        }
    },

    commaSplit: function(srcNumber) {
        var txtNumber = '' + srcNumber.replace(/,/g,"");
        if (isNaN(txtNumber.replace(/\./,"x")) && txtNumber != "") {
            alert(txtNumber+" does not appear to be a valid whole number. Please try again.");
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
