def dofile(name)
  houses=["rathaus", "fischerviertel", "frauenstrasse",
          "salzstadel", "sedelhof", "deutschhaus"]
  File.open("#{name}.txt") do |f|
    File.open("tmp.data","w") do |of|
      f.each_line do |l|
        if l =~ /^[0-9]+/
          t=$&.to_i
          h={}
          l=$'
          while l =~ /^ *([a-z_]+):([0-9]+)/
            n=$1
            v=$2.to_i
            l=$'
            h[n]=v
          end
          s="#{t/3600.0}"
          houses.each do |n|
            v=h[n]
            v=0 unless v
            s="#{s} #{v}"
          end
          of.puts s
        end
      end
    end
  end
  IO.popen("gnuplot","w") do |f|
    f.puts "set terminal png size 640,256"
    f.puts "set output \"#{name}.png\""
    f.puts "set title \"Freie Plaetze\""
    f.puts "set xrange [0:24]"
    f.puts "set grid"
    z=1
    s=houses.map do |a|
      z+=1
      "\"tmp.data\" using 1:#{z} with lines title \"#{a}\""
    end
    f.puts "plot #{s.join','}"
  end
end

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

fn={}
fn[fnm]=true
begin
  File.open("data/flist") do |f|
    f.each_line do |l|
      fn[l.strip]=true
    end
  end
rescue Errno::ENOENT
end
File.open("data/flist","w") do |f|
  fn.keys.sort.reverse[0..7].each do |n|
    f.puts n
  end
end
