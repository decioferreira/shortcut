require 'thor'
Dir[File.dirname(__FILE__) + '/application_tasks/*.rb'].each { |file| require file }

module Shortcut
  class Application < Thor
    register(Shortcut::ApplicationTasks::New, :new, "new [NAME]", "Creates a skeleton for creating a shortcut app")
  end
end
