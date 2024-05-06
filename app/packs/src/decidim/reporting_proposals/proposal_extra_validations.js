$(() => {

  const $title = $('input[name="proposal[title]"]');
  const $body = $('[name="proposal[body]"]');
  const prosemirror = document.querySelector(".ProseMirror");
  const $form = $title.closest("form");

  const findError = ($field, prop) => {
    let $closest = $field.closest("label");
    if (!$closest.length) {
      $closest = $field.closest(".editor");
    }
    let search = `.form-error.${prop}`;
    if (!prop) {
      search = ".form-error"
    }
    let $error = $closest.find(search);
    console.log("findError", "$closest", $closest, " $field", $field, "prop", prop, "$error", $error);
    if ($error.length === 0) {
      $error = $(`<span class="${search.replace(/\./g, " ")}"></span>`).appendTo($closest);
    }
    return $error;
  };

  const clearErrors = ($field, prop) => {
    findError($field, prop).remove();
  };
  
  const addError = ($field, options, prop) => {
    // console.log("addError", $field, options, prop)
    let $error = findError($field, prop);
    $error.addClass("is-visible");
    if (options && options[prop]) {
      $error.html(options[prop].error);
    }
    else {$error.html(Decidim.ProposalRules.genericError);}
  };
  
  const validate = ($field, value, options) => {
    console.log("validate", $field, value, options);

    // validate caps if needed
    const minLen = $field.attr("minlength");

    if (options && options.caps.enabled) {
      if (value.charAt(0) !== value.charAt(0).toUpperCase()) {
        addError($field, options, "caps");
        return false;
      }
    }
    if (minLen && value.length < minLen) {
      addError($field);
      return false;
    }
    return true;
  }
  
  if ($title.length > 0) {
    $title.change(() => {
      clearErrors($title, "caps");
    });
    if (prosemirror) {
      // on change prosemirror (tiptap is not available as a global object)
      prosemirror.addEventListener("focus", () => {
        clearErrors($body, "caps");
      });
      prosemirror.addEventListener("blur", () => {
        clearErrors($body, "caps");
        clearErrors($body);
      });
    } else {
      $body.change(() => {
        clearErrors($body, "caps");
        clearErrors($body);
      });
    }
    $form.on("submit", (ev) => {
      if (!validate($title, $title.val(), Decidim.ProposalRules.title)) {
        ev.preventDefault();
      }
      if (!validate($body, prosemirror
        ? prosemirror.textContent
        : $body.val(), Decidim.ProposalRules.body)) {
        ev.preventDefault();
      }
    });
  }
});
