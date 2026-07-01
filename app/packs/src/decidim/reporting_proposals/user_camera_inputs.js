$(() => {
  $(".camera-container").each(function () {
    const $container = $(this);
    const $input = $container.find("input[type='file']");
    const $button = $container.find(".user-device-camera");
    if ($input.length === 0 || $button.length === 0) {
      return;
    }

    // FormBuilderOverride wraps every file field in .camera-container, but the
    // camera capture and has_no_image wiring must apply to the photo field only.
    // The button's data-input is "add_photos" for photos and "add_attachments"/
    // "add_documents" otherwise; skip non-photo fields. Allowed file types are
    // server-driven (upload validations), so we never set "accept" here.
    const cameraInput = $button.attr("data-input") || "";
    if (!cameraInput.includes("photo")) {
      return;
    }

    const inputId = $input.attr("id");
    const $checkbox = $("#proposal_has_no_image");
    const $formError = $container.find(".form-error");
    const $labelInput = inputId ? $(`label[for='${inputId}']`) : $();

    // The upload-modal trigger button (e.g. #proposal_photos_button) sits outside
    // the camera-container; link it back through the dialog id so it is greyed out too.
    const modalId = $container.closest("[data-dialog]").attr("data-dialog");
    const $trigger = modalId ? $(`[data-dialog-open='${modalId}']`) : $();

    const removeErrors = () => {
      $input.removeClass("is-invalid-input");
      $formError.removeClass("is-visible");
      $labelInput.removeClass("is-invalid-label");
    };

    const toggleInput = () => {
      const disabled = $checkbox.length > 0 && $checkbox[0].checked;
      if (disabled) {
        removeErrors();
      }
      $input.prop("disabled", disabled);
      $button.prop("disabled", disabled);
      $trigger.prop("disabled", disabled);
    };

    $button.on("click", () => {
      $input.attr("capture", "camera");
      $input.click();
      $input.removeAttr("capture");
    });

    $input.on("click", () => {
      $input.one("blur", removeErrors);
    });

    if ($checkbox.length > 0) {
      $checkbox.on("change", toggleInput);
      toggleInput();
    }
  });

  // Foundation's data-close only hides the thumbnail; remove the node so its
  // hidden photos[] field stops being submitted and the photo is deleted.
  $(document)
    .off("click.reportingProposalsPhoto")
    .on("click.reportingProposalsPhoto", ".photos_container .gallery__item .close-button[data-close]", (event) => {
      event.preventDefault();
      $(event.currentTarget).closest(".gallery__item").remove();
    });
});
