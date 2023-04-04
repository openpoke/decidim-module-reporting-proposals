$(() => {
  $("#proposal_answer_template_chooser").change(function() {
    let dropDown =  $("#proposal_answer_template_chooser");
    $.getJSON(dropDown.data("url"), {
      id: dropDown.val(),
      /* eslint camelcase: [0] */
      proposal_id: dropDown.data("proposal")
    }).done(function(data) {
      $(`#proposal_answer_internal_state_${data.state}`).trigger("click");

      let $editors = dropDown.parent().parent().find(".tabs-panel").find(".editor-container");
      $editors.each(function(index, element) {
        let localElement = $(element);
        let $locale = localElement.siblings("input[type=hidden]").attr("id").replace("proposal_answer_answer_", "");
        let editor = Quill.find(element);
        let delta = editor.clipboard.convert(data.template[$locale]);
        editor.setContents(delta);
      });
    });
  });
});
