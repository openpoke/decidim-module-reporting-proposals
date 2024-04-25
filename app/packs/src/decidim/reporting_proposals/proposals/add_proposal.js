import attachGeocoding from "src/decidim/geocoding/attach_input"

$(() => {
  const $checkbox = $("input:checkbox[name$='[has_no_address]']");
  const $hasAdressInput = $("input[name$='[has_address]']");
  const $addressInput = $("#address_input");
  const $addressInputField = $("[data-decidim-geocoding]");
  const $map = $("#address_map");
  let latFieldName = "proposal[latitude]";
  let longFieldName = "proposal[longitude]";
  const $labelInput = $("label[for='proposal_address']");
  const $buttonLocation = $(".user-device-location button");

  if ($map.length) {
    $map.hide();
    $addressInputField.on("geocoder-suggest-coordinates.decidim", () => $map.show());

    // Handle no address checkbox in reverse, mandatory by default instead of default decidim
    if ($checkbox.length > 0) {
      const toggleInput = () => {
        $hasAdressInput.val($checkbox[0].checked
          ? 0
          : 1);

        if ($checkbox[0].checked) {
          const $formError = $labelInput.find('span.form-error[style="display: block;"]');

          $map.hide();
          $addressInputField.prop("disabled", true);
          $addressInputField.removeClass("is-invalid-input");
          $labelInput.removeClass("is-invalid-label");
          $buttonLocation.prop("disabled", true);
          $formError.attr("style", "display:none;");

        } else {
          if ($(`input[name='${latFieldName}']`).val()) {
            $map.show();
          }
          $addressInputField.prop("disabled", false);
          $buttonLocation.prop("disabled", false);
        }
      }
      toggleInput();
      $checkbox.on("change", toggleInput);
    }

    $("[data-decidim-map]").on("ready.decidim", () => {
      if ($addressInput.length <= 0) {
        return;
      }
      const ctrl = $("[data-decidim-map]").data("map-controller");
      ctrl.setEventHandler("coordinates", (ev) => {
        $(`input[name='${latFieldName}']`).val(ev.lat);
        $(`input[name='${longFieldName}']`).val(ev.lng);
      });

      attachGeocoding($addressInputField, null, (coordinates) => {
        // Remove previous marker when user updates address in address field
        ctrl.removeMarker();
        ctrl.addMarker({
          latitude: coordinates[0],
          longitude: coordinates[1],
          address: $addressInputField.val()
        });
      });
    });
  }
});
