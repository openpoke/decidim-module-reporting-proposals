document.addEventListener("turbo:load", () => {
  $(".camera-container").each(function () {
    const $container = $(this);
    const $input = $container.find("input[type='file']");
    const $button = $container.find(".user-device-camera");
    if ($input.length === 0 || $button.length === 0) {
      return;
    }

    // The checkbox and the upload-modal trigger both live outside the modal;
    // reach them through the form attribute name and the dialog id.
    const $checkbox = $("input[type='checkbox'][name$='[has_no_attachments]']");
    const modalId = $container.closest("[data-dialog]").attr("data-dialog");
    const $trigger = modalId
      ? $(`[data-dialog-open='${modalId}']`)
      : $();

    const toggleInput = () => {
      const disabled = $checkbox.length > 0 && $checkbox[0].checked;
      $button.prop("disabled", disabled);
      $trigger.prop("disabled", disabled);
    };

    $button.on("click", () => {
      $input.attr("capture", "camera");
      $input.click();
      $input.removeAttr("capture");
    });

    if ($checkbox.length > 0) {
      $checkbox.on("change", toggleInput);
      toggleInput();
    }
  });
});
