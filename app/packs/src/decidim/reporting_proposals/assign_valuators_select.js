import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("DOMContentLoaded", () => {
  const select = document.querySelector("#assign_valuator_role_ids");

  if (!select) {return;}

  const { noResults } = select.dataset;

  const config = {
    plugins: ["remove_button"],
    render: {
      item: (data, escape) =>
        `<div>${escape(data.text)}<input type="hidden" name="valuator_role_ids[]" value="${data.value}" /></div>`,
      // eslint-disable-next-line camelcase
      ...(noResults && {
        no_results: () => `<div class="no-results">${noResults}</div>`
      })
    }
  };

  return new TomSelect(select, config);
});
