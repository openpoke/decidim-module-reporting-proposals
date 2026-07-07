import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("turbo:load", () => {
  const selects = document.querySelectorAll(".js-taxonomy-evaluators-multiselect");

  selects.forEach((select) => {
    return new TomSelect(select, {
      plugins: ["remove_button", "dropdown_input"],
      allowEmptyOption: true
    });
  });
});
