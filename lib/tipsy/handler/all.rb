Dir.glob(File.dirname(__FILE__) << "/*.rb").each do |path|
  next if File.basename(path) == __FILE__ 
  require path
end