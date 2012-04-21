    YAHOO.util.Event.onDOMReady(function(){
        new YAHOO.util.Element(document.getElementsByTagName('body')[0]).addClass('yui-skin-sam');
        
        var textAreas = document.getElementsByTagName('textarea');
        for (var i = 0; i < textAreas.length; i++) {
            var textArea = textAreas[i];
            if (new YAHOO.util.Element(textArea).hasClass('rich_text_editor')) {
                var editor = new YAHOO.widget.SimpleEditor(textArea.id, {
                    handleSubmit: true,
                    autoHeight: true,
                    dompath: false,
                    collapse: true,
                    height: '100px',
                    width: '530px',
                    markup: 'default',
                    toolbar: {
                        collapse: true,
                        draggable: false,
                        buttonType: 'advanced',
                        buttons: [{
                            group: 'textstyle',
                            label: ' ',
                            buttons: [{
                                type: 'push',
                                label: 'Bold CTRL + SHIFT + B',
                                value: 'bold'
                            }, {
                                type: 'push',
                                label: 'Italic CTRL + SHIFT + I',
                                value: 'italic'
                            }, {
                                type: 'push',
                                label: 'Underline CTRL + SHIFT + U',
                                value: 'underline'
                            }, {
                                type: 'separator'
                            }, {
                                type: 'push',
                                label: 'Create an Unordered List',
                                value: 'insertunorderedlist'
                            }, {
                                type: 'separator'
                            }, {
                                type: 'push',
                                label: 'HTML Link CTRL + SHIFT + L',
                                value: 'createlink'
                            }]
                        }]
                    }
                });
                // MyExtension.install(editor);;
                editor.render();
	            }
        }
    });