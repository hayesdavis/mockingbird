desc "Run tests"
task :test do
  test_base = File.join(File.expand_path(File.dirname(__FILE__)),"test")
  require File.join(test_base,"test_helper")

  Dir.glob("#{test_base}/**/*_test.rb") do |file|
    require File.expand_path(file)
  end
end