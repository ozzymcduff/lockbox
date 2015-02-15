require_relative "lockbox_transform"

lt=LockboxTransform.new()

hashes = lt.to_hash(File.read(ARGV[0]))
require "csv"
def trim(str)
    str.strip.gsub("^\n","").gsub("\n$", "")
end
def guess_user_name(info)
    trim(info.lines.first)
end
def guess_password(info)
    trim(info.lines.last)
end
def rest_of_info(info)
    if info.lines.length>2
        return trim(info.lines.drop(1).take(info.lines.length-2).join("\n"))
    else
        return ""
    end
end
def parse(h)
    i = trim(h[:Information])
    r = rest_of_info(i)
    notes = []
    if h[:Notes]!=nil && ! trim(h[:Notes]).empty?
        notes<<trim(h[:Notes])
    end
    if r && !r.empty? 
        notes<< "\nInformation: "+r
    end
    {:title=>h[:Title],
    :username=>guess_user_name(i),
    :password=>guess_password(i),
    :category=>h[:Category],
    :notes=>notes.join("\n")
    }
end
CSV.open("#{ARGV[0]}.csv", "wb") do |csv|
    csv << ["url", "username", "password", "extra", "name","grouping", "fav"]
    hashes.each do |h|
        h2 = parse(h)
        #puts h2
        #url,username,password,extra,name,grouping,fav

        csv << ["",h2[:username],h2[:password], h2[:Notes], h2[:title], h2[:category], ""]
    end
end
