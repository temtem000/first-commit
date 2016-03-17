# first-commit
require "open-uri"
 
open("URL") do |uri|
    File.open("result.html", "w") do |html|
        html.puts(uri.read)
    end
end
