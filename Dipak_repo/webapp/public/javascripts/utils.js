
NL.ErrorHandler = Class.create();
NL.ErrorHandler.prototype = {

    handleRequestFailure: function(resultResponse, statusCode) {
        alert('A problem occurred on the server. Tech support has been notified. Please try again later.');
    },

    handleRequestException: function(request,e) {
        alert('A problem occurred on the server. Tech support has been notified. Please try again later.');
    },

    initialize: function() {
    }
}
