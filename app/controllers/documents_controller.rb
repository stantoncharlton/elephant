class DocumentsController < ApplicationController
    before_filter :signed_in_user, only: [:show, :new, :create, :update, :destroy]

    respond_to :js

    def show

        respond_to do |format|
            format.xml {
                @document = Document.find(params[:id])
                not_found unless @document.company == current_user.company

                sts = AWS::STS.new()
                policy = AWS::STS::Policy.new
                policy.allow(
                        :actions => ["s3:PutObject"],
                        :resources => "arn:aws:s3:::elephant-docs/*")

                session = sts.new_federated_session(
                        'User_' + current_user.id.to_s,
                        :policy => policy,
                        :duration => 2*60*60)

                record = Struct.new(:url, :accessKeyId, :secretAccessKey, :sessionToken) do
                    def to_xml
                        "<document><url>#{url}</url><uploadKey>docs/#{SecureRandom.hex}</uploadKey><accessKeyId>#{accessKeyId}</accessKeyId><secretAccessKey>#{secretAccessKey}</secretAccessKey><sessionToken>#{sessionToken}</sessionToken></document>"
                    end
                end

                puts session.credentials[:access_key_id]
                puts session.credentials[:secret_access_key]
                puts session.credentials[:session_token]

                #s3 = AWS::S3.new(session.credentials)
                #objg = s3.get_object("docs/009bff23c7e5bf382c9504a072cb0936/photo.JPG")


                #s3.buckets["elephant-docs"].objects["file.pdf"].write(:file => "/Users/t23/Downloads/ConsoleApplication1/UploadHelper/UploadFile.cs")
                #puts "Uploaded................."

                #bucket = s3.buckets["elephant-docs"].objects.collect(&:key)
                #puts "No. of Objects = #{bucket.count.to_s}"
                #puts bucket

                render xml: record.new(@document.full_url,
                                       session.credentials[:access_key_id],
                                       session.credentials[:secret_access_key],
                                       session.credentials[:session_token]).to_xml
            }
        end
    end

    def new

        if params["modal"].present? && params["modal"] == "true"
            @job_id = params[:job_id]
            @document = Document.new
            render 'documents/new_modal'
        else

            @document = Document.new(params[:document])
            @filename ||= File.basename(@document.url)

            render 'documents/new'
        end

    end

    def create

        job_id = params[:document][:job_id]
        params[:document].delete(:job_id)

        job_template_id = params[:document][:job_template_id]
        params[:document].delete(:job_template_id)

        @document = Document.new(params[:document])
        @document.company = current_user.company

        if @document.template?

            @document.job_template = JobTemplate.find_by_id(job_template_id)

            if !@document.save
                render 'error'
            end

            Activity.add(self.current_user, Activity::DOCUMENT_CREATED, @document, @document.name)
        else

            @job = Job.find_by_id(job_id)
            not_found unless @job.company == current_user.company
            @document.job = @job

            if @document.save
                render 'documents/create_modal'
            else
                render 'error'
            end

        end

    end

    def update
        @document = Document.find(params[:id])
        not_found unless @document.company == current_user.company

        if @document.template?
            not_found unless signed_in_admin?
        end

        @document.user = current_user
        @document.url = params[:document][:url]


        @document.save

        if !@document.template?
            Activity.add(current_user, Activity::DOCUMENT_UPLOADED, @document, @document.file_name, @document.job)
        end

    end


    def destroy
        @document = Document.find(params[:id])
        not_found unless @document.company == current_user.company
        @document.destroy

        if !@document.destroy
            render 'error'
        end

        Activity.add(self.current_user, Activity::DOCUMENT_DESTROYED, @document, @document.name)

    end

end
