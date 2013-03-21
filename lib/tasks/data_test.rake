task :create_fake_data => :environment do
    puts "sdfsfsd"
    Company.new.create_fake_data
end