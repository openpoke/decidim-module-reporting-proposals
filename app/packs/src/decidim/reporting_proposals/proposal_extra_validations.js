$(() => {

	const $title = $('input[name="proposal[title]"]');
	const $body = $('textarea[name="proposal[body]"]');
	const $form = $title.closest("form");

	const findError = ($field, prop) => {
		if(!prop) {
			return $field.closest("label").find(".form-error");
		}
		let $error = $field.closest("label").find(".form-error." + prop);
		if($error.length === 0) {
			$error = $('<span class="form-error ' + prop + '"></span>').appendTo($field.closest("label"));
		}
		return $error;
	};

	const clearErrors = ($field, prop) => {
		findError($field, prop).remove();
	};
	
	const addError = ($field, options, prop) => {
		$field.addClass("is-invalid-input");
		let $error = findError($field, prop);
		$error.addClass("is-visible");
		if(options && prop) $error.html(options[prop].error);
	};
	
	const validate = ($field, options) => {
		// validate caps if needed
		const minLen = $field.attr("minlength");
		const value = $field.val();

		if(options && options.caps.enabled) {
			if(value.charAt(0) !== value.charAt(0).toUpperCase()) {
				addError($field, options, "caps");
				return false;
			}
		}
		if(minLen && value.length < minLen) {
			addError($field);
			return false;
		}
		return true;
	}
	
	if($title.length > 0 && $body.length > 0) {
		$title.change(() => {
			clearErrors($title, "caps");
		});
		$body.change(() => {
			clearErrors($body, "caps");
		});
		$form.on("submit", (ev) => {
			if(!validate($title, Decidim.ProposalRules.title)) {
				ev.preventDefault();
			}
			if(!validate($body, Decidim.ProposalRules.body)) {
				ev.preventDefault();
			}
		});
	}
});