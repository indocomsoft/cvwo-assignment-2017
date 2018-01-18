function addAlert(msg) {
  const timestamp = new Date().getTime();
  $('#alerts').append(`<div class="alert alert-warning alert-dismissible fade show inner" role="alert" id="${timestamp}">
                        ${msg}
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">'
                        <span aria-hidden="true">&times;</span>'
                        </button>'
                        </div>`);
  setTimeout(() => { $(`#${timestamp}`).alert('close'); }, 3000);
}

function update(id) {
  const value = $(`#done-${id}`).is(':checked');
  $.post(`/tasks/${id}/done`, { id, value })
    .done((msg) => {
      addAlert(msg.success ? `${msg.name} is ${value ? 'checked' : 'unchecked'}.`
        : `Failed to update ${msg.name}, please try again.`);
    })
    .fail(() => {
      addAlert('Connection failed while updating. Please <a href="javascript:location.reload()">refresh</a> the page.');
    });
}
