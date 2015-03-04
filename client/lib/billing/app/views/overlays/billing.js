import OverlayView from 'tahi/views/overlay';

export default OverlayView.extend({
  templateName: 'overlays/billing',
  layoutName:   'layouts/overlay',
  cardName: 'billing',

  didInsertElement: function() {
    var choice = $(".payment-method .select2-container").select2("val");
    this.get("controller").set("selectedPaymentMethod", choice);
  }
});
