module FakeDataHelper
    def create
        company = Company.new(
                :name => Faker::Lorem.words(1).first.to_s.capitalize
        )
        company.save
        puts company.name

        role = UserRole.new(
                :title => "User",
                :global_modify => true
        )
        role.company = company
        role.save

        300.times do |i|
            begin
                district = District.new(
                        :name => Faker::Lorem.words(Random.new.rand(1..3).to_i).join(" ").to_s.capitalize,
                        :region => Faker::Lorem.words(1).first.to_s.capitalize,
                        :support_email => Faker::Internet.email,
                        :phone_number => Faker::PhoneNumber.phone_number,
                        :address_line_1 => Faker::Address.street_address,
                        :city => Faker::Lorem.words(1).first.to_s.capitalize,
                        :postal_code => Faker::Address.postcode
                )
                district.company = company
                district.country = Country.order('RANDOM()').limit(1).first
                district.save
                puts "District: " + district.name

                30.times do |i|
                    begin
                        field = Field.new(
                                :name => Faker::Lorem.words(1).first.to_s.capitalize,
                        )
                        field.company = company
                        field.district = district
                        field.save
                        puts "Field: " + field.name

                        5.times do |w|
                            well = Well.new(
                                    :name => Faker::Lorem.words(1).first.to_s.capitalize,
                            )
                            well.company = company
                            well.field = field
                            well.save
                            puts "Well: " + well.name
                        end
                    rescue

                    end
                end

            rescue

            end
        end

        10.times do |i|
            begin
                division = Division.new(
                        :name => Faker::Lorem.words(Random.new.rand(1..4)).join(" ").to_s.capitalize,
                )
                division.company = company
                division.save
                puts "Division: " + division.name


                # Secondary Tools
                10.times do |st|
                    tool = Tool.new(
                            :name => Faker::Lorem.words(Random.new.rand(1..4)).join(" ").to_s.capitalize,
                    )
                    tool.company = company
                    tool.division = division
                    tool.save
                    puts "Secondary Tool: " + tool.name
                end

                8.times do |s|
                    segment = Segment.new(
                            :name => Faker::Lorem.words(Random.new.rand(1..4)).join(" ").to_s.capitalize,
                    )
                    segment.company = company
                    segment.division = division
                    segment.save
                    puts "Segment: " + segment.name

                    5.times do |p|
                        product_line = ProductLine.new(
                                :name => Faker::Lorem.words(Random.new.rand(1..4)).join(" ").to_s.capitalize,
                        )
                        product_line.company = company
                        product_line.segment = segment
                        product_line.save
                        puts "ProductLine: " + product_line.name

                        tools = []
                        # Primary Tools
                        10.times do |pt|
                            tool = Tool.new(
                                    :name => Faker::Lorem.words(1).first.to_s.capitalize,
                            )
                            tool.company = company
                            tool.product_line = product_line
                            tool.save
                            if !tool.new_record?
                                tools << tool
                                puts "Primary Tool: " + tool.name
                            end
                        end

                        failures = []
                        # Failures
                        10.times do |f|
                            failure = Failure.new(
                                    :text => Faker::Lorem.words(10).join(" ").to_s,
                                    :template => true
                            )
                            failure.company = company
                            failure.product_line = product_line
                            failure.save
                            if !failure.new_record?
                                failures << failure
                                puts "Failure: " + failure.text
                            end
                        end

                        7.times do |j|
                            job_template = JobTemplate.new(
                                    :name => Faker::Lorem.words(Random.new.rand(1..6)).join(" ").to_s.capitalize,
                                    :description => Faker::Lorem.words(30).join(" ").to_s
                            )
                            job_template.company = company
                            job_template.product_line = product_line
                            job_template.save
                            puts "JobTemplate: " + job_template.name

                            Random.new.rand(1..10).times do |df|
                                begin
                                    dynamic_field = DynamicField.new(
                                            :name => Faker::Lorem.words(2).join(" ").to_s.capitalize,
                                            :value_type => 12,
                                            :template => true,
                                            :optional => [true, false, false, false, false, false].sample
                                    )
                                    if !dynamic_field.optional
                                        dynamic_field.priority = [true, false, false, false, false, false].sample
                                    end
                                    dynamic_field.company = company
                                    dynamic_field.job_template = job_template
                                    dynamic_field.save
                                    puts "Dynamic Field on Job: " + dynamic_field.name
                                rescue

                                end
                            end

                            Random.new.rand(1..4).times do |doc|
                                begin
                                    document = Document.new(
                                            :name => Faker::Lorem.words(2).join(" ").to_s.capitalize,
                                            :template => true
                                    )
                                    document.category = Document::PRE_JOB
                                    document.company = company
                                    document.job_template = job_template
                                    document.save
                                    puts "Document on Job: " + document.name

                                rescue

                                end
                            end

                            Random.new.rand(1..4).times do |doc|
                                begin
                                    document = Document.new(
                                            :name => Faker::Lorem.words(2).join(" ").to_s.capitalize,
                                            :template => true
                                    )
                                    document.category = Document::POST_JOB
                                    document.company = company
                                    document.job_template = job_template
                                    document.save
                                    puts "Document on Job: " + document.name

                                rescue

                                end
                            end

                            Random.new.rand(1..8).times do |tool|
                                begin
                                    primary_tool = PrimaryTool.new
                                    primary_tool.job_template = job_template
                                    primary_tool.tool = tools.sample
                                    primary_tool.save
                                    puts "Primary Tool on Job Type: " + primary_tool.tool.name
                                rescue

                                end
                            end

                            10.times do |ff|
                                begin
                                    failure = Failure.new
                                    failure.job_template = job_template
                                    failure.failure_master_template = failures.sample
                                    failure.save
                                    puts "Failure on Job: " + failure.failure_master_template.text
                                rescue

                                end
                            end

                        end
                    end
                end

            rescue

            end
        end

        10000.times do |i|
            begin
                user = User.new(
                        :name => Faker::Name.first_name + " " + Faker::Name.last_name,
                        :location => Faker::Lorem.words(1).first.capitalize,
                        :password => "elephant",
                        :password_confirmation => "elephant",
                        :accepted_tou => true,
                        :email => Faker::Internet.email,
                        :phone_number => Faker::PhoneNumber.cell_phone
                )
                user.company = company
                user.role = role
                user.district = District.where("company_id = ?", company.id).order('RANDOM()').limit(1).first
                user.save
                puts "User:  " + user.name

            rescue

            end
        end

        2000.times do |i|
            begin
                client = Client.new(
                        :name => Faker::Lorem.words(Random.new.rand(1..3)).join(" ").to_s.capitalize,
                )
                client.company = company
                client.save
                puts "Client:  " + client.name

            rescue

            end
        end


        500000.times do |i|
            begin
                job = Job.new
                job.company = company
                job.client = Client.where("company_id = ?", company.id).order('RANDOM()').limit(1).first
                job.job_template = JobTemplate.where("company_id = ?", company.id).order('RANDOM()').limit(1).first
                well = Well.where("company_id = ?", company.id).order('RANDOM()').limit(1).first
                job.well = well
                job.field = well.field
                job.district = well.field.district

                job.start_date = Random.new.rand(5.years.ago..(Time.now + 50.days)).to_date

                if job.start_date > Time.now
                    job.status = Job::ACTIVE
                else
                    job.close_date = job.start_date + Random.new.rand(3..15).days
                    job.status = Job::CLOSED
                end

                job.save
                puts "Job:  " + job.id.to_s

                last_user = nil
                Random.new.rand(1..8).times do |jm|
                    begin
                        job_membership = JobMembership.new(:job_role_id => Random.new.rand(1..6))
                        job_membership.user = User.where("company_id = ?", company.id).order('RANDOM()').limit(1).first
                        job_membership.job = job
                        job_membership.save
                        puts "User on Job:  " + job_membership.user.name

                        last_user = job_membership.user

                    rescue

                    end
                end

                if job.status == Job::CLOSED
                    JobProcess.record(last_user, job, company, JobProcess::PRE_JOB_DATA_READY)
                    JobProcess.record(last_user, job, company, JobProcess::APPROVED_TO_SHIP)
                    JobProcess.record(last_user, job, company, JobProcess::POST_JOB_DATA_READY)
                    JobProcess.record(last_user, job, company, JobProcess::APPROVED_TO_CLOSE)
                end

                job.job_template.dynamic_fields.each do |dynamic_field|
                    begin
                        job_dynamic_field = dynamic_field.dup
                        job_dynamic_field.value = Random.new.rand(1..5000)
                        job_dynamic_field.template = false
                        job_dynamic_field.dynamic_field_template = dynamic_field
                        job_dynamic_field.job_template = job.job_template
                        job_dynamic_field.job = job
                        job_dynamic_field.company = company
                        job_dynamic_field.save
                        puts "DF on Job:  " + job_dynamic_field.name

                    rescue

                    end
                end

                Random.new.rand(0..3).times do |fi|
                    begin
                        failure = Failure.new(
                                :template => false
                        )
                        failure.company = company
                        failure.job = job
                        failure.failure_master_template = job.job_template.product_line.failures.order("RANDOM()").limit(1).first
                        failure.save
                        puts "Failure on Job:  " + failure.failure_master_template.text

                    rescue

                    end
                end

            rescue

            end
        end
    end
end



