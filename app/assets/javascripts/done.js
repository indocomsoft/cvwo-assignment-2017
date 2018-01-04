function update(doneid) {
    var value = $("#done-" + doneid).is(":checked");
    $.post("/tasks/" + doneid + "/done", { id: doneid, value: value });
    .done(function(msg) {
        add_alert(status.success ? msg.name + " is " + (value ? "checked." : "unchecked." )
                                 : "Failed to update " + msg.name + ", please try again.");
    })
    .fail(function(xhr, status, error) {
        add_alert("Connection failed while updating. Please <a href=\"javascript:location.reload()\">refresh</a> the page.");
    });
}

function add_alert(msg) {
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