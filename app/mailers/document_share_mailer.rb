class DocumentShareMailer < ActionMailer::Base
    default from: "Elephant <no-reply@go-elephant.com>"

    def share(document_share)
        @document_share = document_share
        mail(:to => "ryan.dawson@go-elephant.com, michael.dawson@go-elephant.com, roberto.schuldes@go-elephant.com",
             :reply_to => @document_share.shared_by.email,
             :subject => "#{@document_share.shared_by.name} shared a document: '#{@document_share.document.name}'")
    end

end