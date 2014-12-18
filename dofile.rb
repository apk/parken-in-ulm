def dofile(name)
  houses=["rathaus", "fischerviertel", "frauenstrasse",
          "salzstadel", "deutschhaus", "theater"]
  data={}
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
          data[t]=h
          s="#{t/3600.0}"
          houses.each do |n|
            v=h[n]
            v=333 unless v
            s="#{s} #{v}"
          end
          of.puts s
        end
      end
    end
  end
  [
    { :a => 1024, :n => "-b", :lw => 3, :h => 384 },
    { :a => 640, :n => "", :lw => 2, :h => 256 },
    { :a => 500, :n => "-n", :lw => 1, :h => 256 }
  ].each do |k|
    IO.popen("gnuplot44","w") do |f|
      f.puts "set terminal png size #{k[:a]},#{k[:h]}"
      f.puts "set output \"#{name}#{k[:n]}.png\""
      f.puts "set title \"Freie Plaetze\""
      f.puts "set xrange [0:24]"
      f.puts "set grid"
      f.puts "set key horizontal"
      z=1
      s=houses.map do |a|
        z+=1
        "\"tmp.data\" using 1:#{z} with lines linewidth #{k[:lw]} title \"#{a}\""
      end
      f.puts "plot #{s.join','}"
    end
  end

  subdata=data.keys.sort[-5..-1]
  if subdata
    File.open("tmp.frag","w") do |of|
      of.puts "<table>"
      houses.each do |i|

        sxy=0
        sx=0
        sy=0
        n=0
        sxx=0
        xmax=0
        ylast=0

        subdata.each do |x|
          a=data[x]
          x=x.to_f
          y=a[i]
          # puts "#{x} #{y}"
          n+=1
          sxy+=x*y
          sx+=x
          sy+=y
          sxx+=x*x
          if xmax<x
            xmax=x
            ylast=y # Times are monotonic, so this works.
          end
        end
        b=(n*sxy-sx*sy)/(n*sxx-sx*sx)
        a=(sxx*sy-sx*sxy)/(n*sxx-sx*sx)

        # puts "a=#{a} b=#{b}"
        if ylast <= 10
          s="Full"
        elsif b < -0.005
          x0=-a/b
          s="In #{((x0-xmax)/60).to_i} minutes"
        else
          if ylast < 50
            s="At #{ylast}"
          else
            s="Good"
          end
        end
        of.puts "<tr><td>#{i}:</td><td>#{ylast} (#{(b*600).to_i})</td><td>#{s}</td>"
        # puts "#{i}: #{s} (#{b.to_s[0..5]}) #{ylast}"
      end
      of.puts "</table>"
    end
  end
end
