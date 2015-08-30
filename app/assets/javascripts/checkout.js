// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {
  $(document).on("click", "#checkout_form_use_billing_as_shipping_address", function() {
    if(this.checked){
      $(this).val("yes")
      $("#shipping-address").fadeOut();
    }else{
      $(this).val("no")
      $("#shipping-address").fadeIn();
    }
  });
});
