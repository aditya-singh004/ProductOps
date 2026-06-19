function csrfToken() {
  return document.querySelector("meta[name='csrf-token']").content;
}

function toast(message) {
  var box = $("#toast");
  box.text(message).addClass("show");
  setTimeout(function() { box.removeClass("show"); }, 2400);
}

$(document).on("click", ".modal-open", function() {
  $($(this).data("target")).addClass("open");
});

$(document).on("click", ".modal-close, .modal", function(event) {
  if (event.target === this) $(this).closest(".modal").removeClass("open");
});

$(document).on("change", ".task-status", function() {
  var select = $(this);
  $.ajax({
    url: select.data("url"),
    method: "PATCH",
    headers: { "X-CSRF-Token": csrfToken() },
    data: { status: select.val(), blocked_reason: select.val() === "blocked" ? "Marked blocked from board" : "" },
    success: function() { toast("Task status updated"); },
    error: function(xhr) { toast((xhr.responseJSON && xhr.responseJSON.errors || ["Update failed"]).join(", ")); }
  });
});

$(document).on("change", ".actual-hours", function() {
  var input = $(this);
  $.ajax({
    url: input.data("url"),
    method: "PATCH",
    headers: { "X-CSRF-Token": csrfToken() },
    data: { actual_hours: input.val() },
    success: function() { toast("Actual hours saved"); },
    error: function() { toast("Could not update actual hours"); }
  });
});

$(document).on("change", ".checklist-toggle", function() {
  var checkbox = $(this);
  var data = {};
  data[checkbox.data("field")] = checkbox.is(":checked");
  $.ajax({
    url: checkbox.closest(".checklist").data("url"),
    method: "POST",
    headers: { "X-CSRF-Token": csrfToken() },
    data: data,
    success: function() { toast("Checklist updated"); },
    error: function() { toast("Checklist update failed"); }
  });
});

$(document).on("click", "#calculate-risk", function() {
  var button = $(this);
  button.prop("disabled", true).text("Calculating...");
  $.ajax({
    url: button.data("url"),
    method: "POST",
    headers: { "X-CSRF-Token": csrfToken() },
    success: function(report) {
      toast("Risk calculated: " + report.risk_level + " " + report.risk_score);
      window.location.reload();
    },
    error: function(xhr) {
      toast((xhr.responseJSON && xhr.responseJSON.error) || "Risk service unavailable");
      button.prop("disabled", false).text("Calculate Risk");
    }
  });
});

$(document).on("click", "#approve-production", function() {
  $.ajax({
    url: $(this).data("url"),
    method: "POST",
    headers: { "X-CSRF-Token": csrfToken() },
    success: function() { toast("Production release approved"); window.location.reload(); },
    error: function(xhr) { toast((xhr.responseJSON && xhr.responseJSON.errors || ["Approval failed"]).join(", ")); }
  });
});
