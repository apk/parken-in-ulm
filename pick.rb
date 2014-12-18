require 'dofile.rb'

h={}
[1,2].each do |iter|
  IO.popen("/usr/bin/wget --tries=1 -O - http://www.parken-in-ulm.de/") do |f|
    n=nil
    z=0
    f.each_line do |l|
      # Just scrape out the relevant lines. We could use Rexml
      # to properly parse the stuff, but then, it will break
      # either way when they change the page.
      if l =~ /onClick="fenster\('parkhaeuser\/([a-z_]+)'\)">/
        n=$1
        z=0
      elsif l =~ /<td align="left" valign="middle">([0-9]+)<\/td>/ or
            l.gsub(/&#160;/,'') =~ /<td align="left" valign="top">([0-9]+)<\/td>/
        # puts "n=#{n.inspect} #{z.inspect}"
        if n
          v=$1
          z+=1
          if z==2
            h[n]=v.to_i
            n=nil
          end
        end
      else
        n=nil
      end
    end
  end
  puts "h: #{h.inspect}"
  break unless h.empty?
end

if h.empty?
  puts "No data?"
  exit
end

t=Time.now().to_i
s=(t%86400).to_s
h.keys.sort.each do |k|
  s+=" #{k}:#{h[k]}"
end
fnm="data/#{t/86400}"
File.open("#{fnm}.txt","a") do |f|
  f.puts s
end

dofile(fnm)

fn=[fnm]
begin
  File.open("data/flist") do |f|
    f.each_line do |l|
      fn<<=l.strip
    end
  end
rescue Errno::ENOENT
end
File.open("data/flist","w") do |f|
  fn.sort.uniq.reverse[0..8].each do |n|
    f.puts n
  end
end
