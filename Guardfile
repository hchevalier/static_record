guard :rspec, all_on_start: true,
              cmd_additional_args: '--tty --color',
              cmd: 'bundle exec rspec' do
  watch(%r{^lib|app/(.+).rb$}) do |m|
    "spec/#{m[1]}_spec.rb"
  end

  watch(%r{^spec/(.+).rb$}) do |m|
    "spec/#{m[1]}.rb"
  end
end
