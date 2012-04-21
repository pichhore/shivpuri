desc "Use the usesguid plugin to generate some UUIDs for well-known data"
task :generate_uuids do
  require "vendor/plugins/guid/lib/uuid22"
  1.upto(25) do
    puts UUID.timestamp_create().to_s22
  end
end
