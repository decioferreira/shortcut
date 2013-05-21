require 'thor'

module Shortcut
  module ApplicationTasks
    class New < Thor::Group
      include Thor::Actions

      argument :name

      def self.source_root
        File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def skeleton
        app_name = name.chomp("/") # remove trailing slash if present
        namespaced_path = app_name.tr('-', '/')
        target = File.join(Dir.pwd, app_name)
        constant_name = app_name.split('_').map{|p| p[0..0].upcase + p[1..-1] }.join
        constant_name = constant_name.split('-').map{|q| q[0..0].upcase + q[1..-1] }.join('::') if constant_name =~ /-/
        constant_array = constant_name.split('::')
        git_user_name = `git config user.name`.chomp
        git_user_email = `git config user.email`.chomp
        opts = {
          :name            => app_name,
          :namespaced_path => namespaced_path,
          :constant_name   => constant_name,
          :constant_array  => constant_array,
          :author          => git_user_name.empty? ? "TODO: Write your name" : git_user_name,
          :email           => git_user_email.empty? ? "TODO: Write your email address" : git_user_email,
          :test            => options[:test]
        }
        gemspec_dest = File.join(target, "#{app_name}.gemspec")
        template("Gemfile.tt",                   File.join(target, "Gemfile"),                           opts)
        template("Rakefile.tt",                  File.join(target, "Rakefile"),                          opts)
        template("LICENSE.txt.tt",               File.join(target, "LICENSE.txt"),                       opts)
        template("README.md.tt",                 File.join(target, "README.md"),                         opts)
        template("gitignore.tt",                 File.join(target, ".gitignore"),                        opts)
        template("newgem.gemspec.tt",            gemspec_dest,                                           opts)
        template("lib/newgem.rb.tt",             File.join(target, "lib/#{namespaced_path}.rb"),         opts)
        template("lib/newgem/version.rb.tt",     File.join(target, "lib/#{namespaced_path}/version.rb"), opts)
        template("bin/newgem.tt",                File.join(target, 'bin', app_name),                     opts)
        case options[:test]
        when 'rspec'
          template("rspec.tt",                   File.join(target, ".rspec"),                            opts)
          template("spec/spec_helper.rb.tt",     File.join(target, "spec/spec_helper.rb"),               opts)
          template("spec/newgem_spec.rb.tt",     File.join(target, "spec/#{namespaced_path}_spec.rb"),   opts)
        when 'minitest'
          template("test/minitest_helper.rb.tt", File.join(target, "test/minitest_helper.rb"),           opts)
          template("test/test_newgem.rb.tt",     File.join(target, "test/test_#{namespaced_path}.rb"),   opts)
        end
        if options[:test]
          template(".travis.yml.tt",             File.join(target, ".travis.yml"),                       opts)
        end
        say "Initializating git repo in #{target}"
        Dir.chdir(target) { `git init`; `git add .` }

        if options[:edit]
          run("#{options["edit"]} \"#{gemspec_dest}\"")  # Open gemspec in editor
        end
      end

    end
  end
end
