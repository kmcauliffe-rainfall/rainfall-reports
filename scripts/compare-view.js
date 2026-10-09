(function () {
  var MAP = {
    "v1-jun25": { dir: "v1-jun25", max: 12, label: "v1" },
    "v3-published": { dir: "v3-published", max: 11, label: "v3" },
    "v5-final": { dir: "v5-final", max: 11, label: "v5" },
  };

  function pad(n) {
    return n < 10 ? "0" + n : "" + n;
  }

  function pageUrl(key, page) {
    var spec = MAP[key];
    if (!spec) return "";
    return "../assets/facsimile/" + spec.dir + "/page-" + pad(page) + ".png";
  }

  function render() {
    var left = document.getElementById("cmp-left").value;
    var right = document.getElementById("cmp-right").value;
    var page = parseInt(document.getElementById("cmp-page").value, 10) || 1;
    var grid = document.getElementById("compare-grid");
    if (!grid) return;
    grid.innerHTML =
      '<div class="facsimile-page-wrap"><span class="facsimile-page-label">' +
      MAP[left].label +
      " p." +
      page +
      '</span><img class="facsimile-page" src="' +
      pageUrl(left, page) +
      '" alt="left"></div>' +
      '<div class="facsimile-page-wrap"><span class="facsimile-page-label">' +
      MAP[right].label +
      " p." +
      page +
      '</span><img class="facsimile-page" src="' +
      pageUrl(right, page) +
      '" alt="right"></div>';
  }

  document.addEventListener("DOMContentLoaded", function () {
    var btn = document.getElementById("cmp-go");
    if (btn) btn.addEventListener("click", render);
    render();
  });
})();
