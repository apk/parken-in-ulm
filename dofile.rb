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
  [
    { :a => 640, :n => "" },
    { :a => 500, :n => "-n" }
  ].each do |k|
    IO.popen("gnuplot44","w") do |f|
      f.puts "set terminal png size #{k[:a]},256"
      f.puts "set output \"#{name}#{k[:n]}.png\""
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
end
