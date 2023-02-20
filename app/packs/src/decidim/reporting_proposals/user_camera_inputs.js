$(() => {
  $('input[name="proposal[add_photos]"]').each((_i, el) => {
    const $input = $(el);
    const $inputField = $input.closest(".row.column");
    const $button = $inputField.find("button:first");
    const $checkbox = $inputField.find("input:checkbox[name$='[has_no_image]']");
    const $formError = $("span.form-error")
    const $labelInput = $("label[for='proposal_add_photos']")

    $input.attr("accept", "image/*");

    $button.on("click", () => {
      $input.attr("capture", "camera");
      $input.click();
      $input.removeAttr("capture", "camera");
    });

    const removeErrors = () => {
      $input.removeClass("is-invalid-input");
      $formError.removeClass("is-visible");
      $labelInput.removeClass("is-invalid-label");
    };

    const toggleInput = () => {
      if ($checkbox[0].checked) {
        $input.prop("disabled", true);
        $button.prop("disabled", true);
        removeErrors();
      } else {
        $input.prop("disabled", false);
        $button.prop("disabled", false);
      }
    };

    $input.on("blur", () => {
      removeErrors();
    });

    if ($checkbox.length > 0) {
      $checkbox.on("change", toggleInput);
      toggleInput();
    }
  });
}); 
