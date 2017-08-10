// Summernote
//
$.summernote.options.callbacks.onImageUpload = function(files) {
  // Dumb but a default or instance callback required to get the
  // event handler to fire.
  console.log('image upload:', files);
}
$.summernote.options.toolbar = [
  ['style', ['style']],
  ['font', ['bold', 'italic', 'underline', 'clear']],
  // ['font', ['bold', 'italic', 'underline', 'strikethrough', 'superscript', 'subscript', 'clear']],
  // ['fontname', ['fontname']],
  // ['fontsize', ['fontsize']],
  //['color', ['color']],
  ['para', ['ul', 'ol', 'paragraph']],
  //['height', ['height']],
  //['table', ['table']],
  //['insert', ['link', 'picture', 'hr']],
  ['insert', ['link', 'picture', 'hr']],
  ['view', ['fullscreen', 'codeview']],
  ['help', ['help']]
];

// Summernote Event Handlers
$(document).on('turbolinks:load', function() {
  $('.editor-field').on('summernote.init', function(event) {

    // Material Kit Hack
    //$('.note-toolbar .btn-default').
    //  removeClass('btn-default').addClass('btn-simple');

    //$('.note-popover').css({'display': 'none'}); // BS4 HACK
    var $editor = $(event.target),
        $input = $($editor.data('input'));
    if ($input.val().length > 0) $editor.summernote('code', $input.val());
  }).on('summernote.change', function(event, contents, $editable) {
    var $editor = $(event.target),
        $input = $($editor.data('input'));
    $input.val(contents);
  }.bind(window)).on('summernote.image.upload', function(event, files) {
    console.log('upload event');
    for (var i = 0; i < files.length; i++) {
      var file = files[i],
          reader = new FileReader();
      reader.onloadend = function() {
        $.ajax({
          method: 'POST',
          url: '/embedded-images',
          dataType: 'json',
          contentType: 'application/json',
          data: JSON.stringify({
            asset_url: reader.result,
            asset_name: file.name
          })
        }).fail(function(data, textStatus, jqXHR){
          console.log('IMAGE UPLOAD FAIL', textStatus);
        }).done(function(data, textStatus, jqXHR){
          $(event.target).summernote(
            'insertImage',
            jqXHR.responseJSON.asset_url, jqXHR.responseJSON.asset_name
          );
        });
      };
      reader.readAsDataURL(file);
    }
  });

  $('.editor-field').summernote({
    height: 500,
    minHeight: 100,
    maxHeight: 1200
  });

});
