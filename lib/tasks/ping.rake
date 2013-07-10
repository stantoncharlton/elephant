desc "Pings site to keep a dyno alive"
task :dyno_ping do
    require "net/http"
    uri = URI('https://www.go-elephant.com/')
    Net::HTTP.get_response(uri)
end