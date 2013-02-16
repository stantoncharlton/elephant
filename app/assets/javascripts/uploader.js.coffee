jQuery ->
  connectUploadEvents()

connectUploadEvents = ->
  $('[id=fileupload]').live "DOMActivate", ->
    $(this).fileupload
      add: (e, data) ->
        types = /(\.|\/)(doc|docx|txt|xls|xlsx|pdf)$/i
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          $(e.target).find(".document-info").hide()
          $(e.target).find(".upload-controls").hide()
          data.context = $(tmpl("template-upload", file))
          $(e.target).append(data.context)
          data.submit()
        else
          alert("#{file.name} is not a doc, docx, txt, xls, xlsx, or pdf file")

      progress: (e, data) ->
        if data.context
          progress = parseInt(data.loaded / data.total * 100, 10)
          data.context.find('.bar').css('width', progress + '%')

      done: (e, data) ->
        $(e.target).find('.document-info').show()
        $(e.target).find(".upload-controls").show()
        documentId = $(e.target).find('.upload-controls').attr('id').replace('div_upload_', '')
        filename = $(e.target).find('.document-name').text()
        file = data.files[0]
        domain = $(e.target).attr('action')
        path = $(e.target).find('input[name=key]').val().replace('${filename}', file.name)
        #path = $(e.target).find('input[name=key]').val().replace('${filename}', documentId + ": " + filename + "." + file.name.substr((file.name.lastIndexOf('.') + 1)))
        to = $(e.target).data('post')
        content = {}
        content[$(e.target).data('as')] = path

        $.ajax
          url: to
          dataType: "script"
          data: content
          type: "PUT"
          success: ->
            $(this).addClass "done"

        data.context.remove() if data.context # remove progress bar

      fail: (e, data) ->
        $(e.target).find('.document-info').show()
        $(e.target).find(".upload-controls").show()
        data.context.remove()
        alert("#{data.files[0].name} failed to upload.")
        console.log("Upload failed:")
        console.log(data)
