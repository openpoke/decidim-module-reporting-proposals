$(() => {
  $("#proposal_answer_template_chooser").change(() => {
    const $dropDown =  $("#proposal_answer_template_chooser");
    $dropDown.next("#template-error").remove();
    if ($dropDown.val() === "") {
      return;
    }
    $.getJSON($dropDown.data("url"), {
      id: $dropDown.val(),
      /* eslint camelcase: [0] */
      proposal_id: $dropDown.data("proposal")
    }).done((data) => {
      $(`#proposal_answer_internal_state_${data.state}`).trigger("click");

      const $editors = $dropDown.parent().parent().find(".tabs-panel").find(".editor-container");
      $editors.each((index, element) => {
        const localElement = $(element);
        const $locale = localElement.siblings("input[type=hidden]").attr("id").replace("proposal_answer_answer_", "");
        const editor = Quill.find(element);
        const delta = editor.clipboard.convert(data.template[$locale]);
        editor.setContents(delta);
      });
    }).fail((err) => {
      $dropDown.after(`<p id="template-error" class="text-alert">${err.responseJSON.msg || err.responseJSON.error || err.responseJSON}</p>`);
    });
  });
});
