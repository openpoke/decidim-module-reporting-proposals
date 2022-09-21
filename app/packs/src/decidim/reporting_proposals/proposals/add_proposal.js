import attachGeocoding from "src/decidim/geocoding/attach_input"
import getCoordinateInputName from "src/decidim/geocoding/coordinate_input";

$(() => {
  const $checkbox = $("input:checkbox[name$='[has_no_address]']");
  const $hasAdressInput = $("input[name$='[has_address]']");
  const $addressInput = $("#address_input");
  const $addressInputField = $("input[name='proposal[address]']");
  const $map = $("#address_map");
  const $addressFill = $(".address-fill");
  let latFieldName = "proposal[latitude]";
  let longFieldName = "proposal[longitude]";

  // if ($addressInputField.length > 0) {
  //   latFieldName = getCoordinateInputName("latitude", $addressInputField, {})
  //   longFieldName = getCoordinateInputName("longitude", $addressInputField, {})
  // }

  $map.hide();

  if ($checkbox.length > 0) {
    const toggleInput = () => {
    	$hasAdressInput.val($checkbox[0].checked ? 0 : 1);

      if ($checkbox[0].checked) {
        $map.hide();
        $addressInputField.prop("disabled", true);
      } else {
      	if($(`input[name='${latFieldName}']`).val()) {
	        $map.show();
      	}
        $addressInputField.prop("disabled", false);
      }
    }
    // toggleInput();
    $checkbox.on("change", toggleInput);
  }

  if ($addressInput.length > 0) {
    const ctrl = $("[data-decidim-map]").data("map-controller");
    ctrl.setEventHandler("coordinates", (ev) => {
      $(`input[name='${latFieldName}']`).val(ev.lat);
      $(`input[name='${longFieldName}']`).val(ev.lng);
    });

    attachGeocoding($addressInputField, null, (coordinates) => {
      $map.show();
      // Remove previous marker when user updates address in address field
      ctrl.removeMarker();
      ctrl.addMarker({
        latitude: coordinates[0],
        longitude: coordinates[1],
        address: $addressInputField.val()
      });
    });
  }
});
