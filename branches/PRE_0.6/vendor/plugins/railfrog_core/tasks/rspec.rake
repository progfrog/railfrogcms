require 'spec/rake/spectask'

namespace :spec do
  desc "Run the specs under vendor/plugins with rails_spec_runner"
  task :plugins_with_runner do
    spec_files = FileList['vendor/plugins/**/spec/**/*_spec.rb']
    spec_opts = ["-f h"]
    out = " > spec.html"    
    ruby("script/rails_spec #{spec_opts.join(' ')} #{spec_files.join(' ')} #{out}")
  end
  
  desc "Run the specs under vendor/railfrog_core (Use 'rake spec:railfrog RCOV' to run with rcov)"
  Spec::Rake::SpecTask.new(:railfrog => "db:test:prepare") do |t|
    t.spec_files = FileList['vendor/plugins/railfrog_core/spec/**/*_spec.rb']
    t.spec_opts = ["-f s"]
    if ENV["RCOV"]
      t.rcov = true
      t.rcov_opts = ["--rails", "--exclude", '\bspec/,_spec\.rb\z', "--include-file", '"\bvendor\/plugins\/railfrog_core\/(?!spec\/)"']
    end
  end
end