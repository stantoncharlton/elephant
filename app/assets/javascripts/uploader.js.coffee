jQuery ->
  $('#fileupload').fileupload
    add: (e, data) ->
      types = /(\.|\/)(gif|jpe?g|png)$/i
      file = data.files[0]
      if types.test(file.type) || types.test(file.name)
        $('#file_uploads').hide()
        data.context = $(tmpl("template-upload", file))
        $('#fileupload').append(data.context)
        data.submit()
      else
        alert("#{file.name} is not a gif, jpeg, or png image file")

    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.bar').css('width', progress + '%')

    done: (e, data) ->
      $('#file_uploads').show()
      file = data.files[0]
      domain = $('#fileupload').attr('action')
      path = $('#fileupload input[name=key]').val().replace('${filename}', file.name)
      to = $('#fileupload').data('post')
      content = {}
      content[$('#fileupload').data('as')] = path

      $.ajax
        url: to
        dataType: "script"
        data: content
        type: "PUT"
        success: ->
          $(this).addClass "done"

      data.context.remove() if data.context # remove progress bar

    fail: (e, data) ->
      $('#file_uploads').show()
      alert("#{data.files[0].name} failed to upload.")
      console.log("Upload failed:")
      console.log(data)
