function update(doneid) {
  $.post("/tasks/" + doneid + "/done", { id: doneid, value: $("#done-" + doneid).is(":checked") })
    .done(function(msg) {
        if (msg.success) {
            add_alert(msg, doneid, $("#done-" + doneid).is(":checked"));
        } else {
            add_alert(msg, doneid, $("#done-" + doneid).is(":checked"));
        }
    })
    .fail(function(xhr, status, error) {
        add_alert(false, doneid, $("#done-" + doneid).is(":checked"));
    });
}

function add_alert(status, doneid, value) {
    if (status) {
        if (status.success) {
            var message = status.name + " is "
                            + (status.value === "true" ? "checked." : "unchecked.");
        } else {
            var message = "Failed to update " + status.name + ", please try again.";
            $("#done-" + doneid).prop("checked", !status.value);
        }
    } else {
        var message = "Connection failed while updating. Please <a href=\"javascript:location.reload()\">refresh</a> the page.";
        $("#done-" + doneid).prop("checked", !value);
    }
    var d = new Date();
    var timestamp = d.getTime();
    $("#alerts").append(
            '<div class="alert alert-warning alert-dismissible fade show inner" role="alert" id="' + timestamp + '">'
            + message
            + '<button type="button" class="close" data-dismiss="alert" aria-label="Close">'
            + '<span aria-hidden="true">&times;</span>'
            + '</button>'
            + '</div>');
    setTimeout(function() { $("#" + timestamp).alert('close'); }, 3000);
}