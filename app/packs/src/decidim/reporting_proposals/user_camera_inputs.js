$(() => {
  $('input[type="file"]').each((_i, el) => {
    const $input = $(el);
    const $inputField = $input.closest(".row.column");
    const $button = $inputField.find("button:first");
    const $checkbox = $inputField.find("input:checkbox[name$='[has_no_image]']");

    $input.attr("accept", "image/*");

    $button.on("click", () => {
      $input.attr("capture", "camera");
      $input.click();
      $input.removeAttr("capture", "camera")
    });

    if ($checkbox.length > 0) {
      const toggleInput = () => {
        if ($checkbox[0].checked) {
          $input.prop("disabled", true);
          $button.prop("disabled", true);
        } else {
          $input.prop("disabled", false);
          $button.prop("disabled", false);
        }
      }
      $checkbox.on("change", toggleInput);
    }
  });
}); 
