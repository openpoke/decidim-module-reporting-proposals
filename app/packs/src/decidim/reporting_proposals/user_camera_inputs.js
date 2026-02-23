$(() => {
  const $input = $("#proposal_add_photos_button");
  const $button = $(".camera-container .user-device-camera");
  const $checkbox = $("#proposal_has_no_image");
  const $formError = $(".camera-container .form-error")
  const $labelInput = $("label[for='proposal_add_photos']")

  const removeErrors = () => {
    $input.removeClass("is-invalid-input");
    $formError.removeClass("is-visible");
    $labelInput.removeClass("is-invalid-label");
  };

  const toggleInput = () => {
    if ($checkbox[0].checked) {
      removeErrors();
      $input.prop("disabled", true);
      $button.prop("disabled", true);
    } else {
      $input.prop("disabled", false);
      $button.prop("disabled", false);
    }
  }

  $input.attr("accept", "image/*");

  $button.on("click", () => {
    // console.log("click button")
    $input.attr("capture", "camera");
    $input.click();
    $input.removeAttr("capture", "camera");
  });

  $input.on("click", () => {
    // console.log("click", $input);
    $input.one("blur", () => {
      // console.log("blur", $input);
      removeErrors();
    });
  });


  if ($checkbox.length > 0) {
    $checkbox.on("change", toggleInput);
    toggleInput();
  }
}); 
