require 'thor'

class Shortcut::Application < Thor::Group
  include Thor::Actions

  argument :name

  def bundler_gem
    exec("bundle gem #{name}")
  end
end
