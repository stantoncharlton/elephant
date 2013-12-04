class DocumentShareMailer < ActionMailer::Base
    default from: "Elephant <no-reply@elephant-cloud.com>"

    def share(document_share)
        @document_share = document_share
        mail(:to => @document_share.shared_by.company.test_company ? "test-emails@elephant-cloud.com" : @document_share.email,
             :reply_to => @document_share.shared_by.email,
             :subject => "#{@document_share.shared_by.name} shared a document: '#{@document_share.document.name}'")
    end

end
