$(() => {
  const info = ($target, msg) => {
    const $label = $target.closest("label")
    $label.find(".form-error").remove();
    if (msg) {
      $('<span class="form-error"/>').text(msg).appendTo($label).show();
    }
  };

  const setLocating = ($button, enable) => {
    if (enable) {
      $button.addClass("loading-spinner");
      $button.attr("disabled", true);
    } else {
      $button.removeClass("loading-spinner");
      $button.attr("disabled", false);
    }
  }

  $(".user-device-location button").on("click", (e) => {
    const $this = $(e.target);
    if ($this.is(":disabled")) {
      return;
    }

    const $input = $(`#${e.target.dataset.input}`);
    const $latitude = $(`#${e.target.dataset.latitude}`);
    const $longitude = $(`#${e.target.dataset.longitude}`);
    const errorNoLocation = e.target.dataset.errorNoLocation;
    const errorUnsupported = e.target.dataset.errorUnsupported;
    const url = e.target.dataset.url;
    console.log("locator", $input, $latitude, $longitude, url, e);

    if (navigator.geolocation) {
      setLocating($this, true);
      navigator.geolocation.getCurrentPosition((position) => {
        const coordinates  = [position.coords.latitude, position.coords.longitude];
        $input.trigger(
          "geocoder-suggest-coordinates.decidim",
          [coordinates]
        );
        // reverse geolocation
        $.post(url, { latitude: coordinates[0], longitude: coordinates[1] }, (data) => {
          $input.val(data.address)
        })
        setLocating($this, false);
      }, (evt) => { 
        info($input, `${errorNoLocation} ${evt.message}`);
        $this.attr("disabled", false);
      }, {
        enableHighAccuracy: true
      });
    } else {
      info($input, errorUnsupported);
    }
  });
});
