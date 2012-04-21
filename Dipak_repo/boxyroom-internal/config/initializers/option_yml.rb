# This is where we define the loading of external yaml config files

AVAIL_CURRENCY = YAML.load_file("#{RAILS_ROOT}/config/currency.yml").symbolize_keys
