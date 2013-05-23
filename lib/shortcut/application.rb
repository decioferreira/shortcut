require 'thor'
Dir[File.dirname(__FILE__) + '/application_tasks/*.rb'].each { |file| require file }

module Shortcut
  class Application < Thor
    desc "build", "Build runnable archive"
    def build
      exec('warble && mkdir -p pkg && mv *.jar pkg')
    end

    desc "run", "Build and run application"
    def run
      exec('warble && mkdir -p pkg && mv *.jar pkg && java -jar pkg/*.jar')
    end

    method_option :test, :type => :string, :lazy_default => 'rspec', :aliases => '-t', :desc => "Generate a test directory for your application. Supports: 'rspec' (default), 'minitest'"
    method_option :edit, :type => :string, :aliases => "-e",
                  :lazy_default => [ENV['BUNDLER_EDITOR'], ENV['VISUAL'], ENV['EDITOR']].find{|e| !e.nil? && !e.empty? },
                  :required => false, :banner => "/path/to/your/editor",
                  :desc => "Open generated gemspec in the specified editor (defaults to $EDITOR or $BUNDLER_EDITOR)"
    register(Shortcut::ApplicationTasks::New, :new, "new [NAME]", "Creates a skeleton for creating a shortcut app")
  end
end
