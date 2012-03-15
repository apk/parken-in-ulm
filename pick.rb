require 'dofile.rb'

h={}
IO.popen("/usr/bin/wget -O - http://www.parken-in-ulm.de/") do |f|
  n=nil
  z=0
  f.each_line do |l|
    if l =~ /onClick="fenster\('parkhaeuser\/([a-z_]+)'\)">/
      n=$1
      z=0
    elsif l =~ /<td align="left" valign="middle">([0-9]+)<\/td>/
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
  fn.sort.uniq.reverse[0..7].each do |n|
    f.puts n
  end
end
