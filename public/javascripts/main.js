$(function () {
  'use strict';

  // Initialize the jQuery File Upload widget:
  $('#fileupload').fileupload({
    // Uncomment the following to send cross-domain cookies:
    //xhrFields: {withCredentials: true},
    url: '/upload',
    maxChunkSize: 1024 * 1024, //1 megabyte

    add: function (e, data) {
      var that = this;
      $.getJSON('/upload', {file: data.files[0].name}, function (result) {
        var file = result.file;
        data.uploadedBytes = file && file.size;
        $.blueimp.fileupload.prototype.options.add.call(that, e, data);
      });
    },

    done: function (e, data) {
      if(data.result.files) {
        $.each(data.result.files, function (index, file) {
          $('<p/>').text(file.name).appendTo('#files');
        })
      }
    },

    progressall: function (e, data) {
      var progress = parseInt(data.loaded / data.total * 100, 10);
      $('#progress-bar').css('width', progress + '%');
    }
  });

  // Load existing files:
  $('#fileupload').addClass('fileupload-processing');
  $.ajax({
    // Uncomment the following to send cross-domain cookies:
    //xhrFields: {withCredentials: true},
    url: $('#fileupload').fileupload('option', 'url'),
    dataType: 'json',
    context: $('#fileupload')[0]
  }).always(function () {
    $(this).removeClass('fileupload-processing');
  }).done(function (result) {
    $(this).fileupload('option', 'done').call(this, $.Event('done'), {result: result});
  });
});
