function set_blank(field){
  if ( field.value == field.defaultValue || field.value == '' ) { 
    field.value = '';
  }
}

function set_default_value(field){
  if ( field.value == '' ) { 
    field.value = field.defaultValue;
  }
}
