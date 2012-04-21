NL.ErrorHandler = Class.create();
NL.ErrorHandler.prototype = {

    handleRequestFailure: function(resultResponse, statusCode) {
        alert('A problem occurred on the server. Tech support has been notified. Please try again later.\n\nDetails:\nCode: '+statusCode+'\n'+resultResponse);
    },

    handleRequestException: function(request,e) {
        try {
            alert('A problem occurred on the server. Tech support has been notified. Please try again later.\n\nDetails:\n'+e.message+'\n\nfileName:'+e.fileName+'\nlineNumber:'+e.lineNumber+'\nname:'+e.name+'\nstack:'+e.stack);
        } catch(e2) {
            alert('A problem occurred on the server. Tech support has been notified. Please try again later.\n\nDetails:\n'+e);
        }
    },

    initialize: function() {
    }
}