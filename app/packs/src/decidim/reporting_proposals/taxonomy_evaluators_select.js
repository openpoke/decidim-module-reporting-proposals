import TomSelect from "tom-select/dist/cjs/tom-select.popular";

const instances = [];

document.addEventListener("turbo:load", () => {
  const selects = document.querySelectorAll(".js-taxonomy-evaluators-multiselect");

  selects.forEach((select) => {
    if (select.tomselect) {
      return;
    }

    instances.push(new TomSelect(select, {
      plugins: ["remove_button", "dropdown_input"],
      allowEmptyOption: true
    }));
  });
});

// restore pristine selects before Turbo caches the page snapshot
document.addEventListener("turbo:before-cache", () => {
  while (instances.length) {
    instances.pop().destroy();
  }
});
