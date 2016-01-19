var Edgarj = {
};

Edgarj.Popup = {
  /*
  JavaScript version of Edgarj::PopupHelper::PopupField.
  
  This constructor returns exactly the same value as helper does.

  = SEE ALSO
  Edgarj::PopupHelper::PopupField::  same logic at ruby server side
  */
  Field: function(id_target){
    this.id_target          = $('#' + id_target);
    this.label_target       = $('#' + '__edgarj_label_target_for_' + id_target);
    this.label_hidden_field = $('#' + '__edgarj_label_hidden_field_for_' + id_target);
    this.clear_link         = $('#' + this.label_target.attr('id') + '_clear_link');
  },

  /*
  clear popup button and hidden field

  = INPUTS
  id_target::     id target DOM
  text::          default text on clear
  */
  clear: function(id_target, text){
    if(typeof(text)==='undefined') text = '';

    var pf = new this.Field(id_target);
    pf.id_target.val('');
    pf.label_target.text(text);
    pf.label_hidden_field.val('');
    pf.clear_link.hide();
  }
};

Edgarj.OperatorSelection = {
  /*
  set selected operator 'op' into both target label and hidden field
  on search-form.
  */
  on_select: function(target, op){
    // guess hidden field from target label
    var hidden_dom  = target.id.replace(/_label$/, ""),
        hidden      = $('#' + hidden_dom);

    hidden.val(op);
    $(target).text(op);
  }
};
