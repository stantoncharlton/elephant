require 'app/helpers/fake_data_helper.rb'
include FakeDataHelper

task :create_fake_data => :environment do
    create
end