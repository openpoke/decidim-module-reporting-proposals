$(() => {
  $('input[type="file"]').each((_i, el) => {
    const $input = $(el);
    const $inputField = $input.closest(".row.column");
    const $button = $inputField.find("button:first");
    const $checkbox = $inputField.find("input:checkbox[name$='[has_no_image]']");
    const $formError = $inputField.find("span.form-error")
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
      console.log("click button")
      $input.attr("capture", "camera");
      $input.click();
      $input.removeAttr("capture", "camera");
    });

    $input.on("click", () => {
      console.log("click", $input);
      $input.one("blur", () => {
        console.log("blur", $input);
        removeErrors();
      });
    });

    if ($checkbox.length > 0) {
      $checkbox.on("change", toggleInput);
      toggleInput();
    }
  });
}); 
