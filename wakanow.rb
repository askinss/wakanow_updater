require 'soap/wsdlDriver'
require 'digest/md5'
require 'yaml'
require 'logger'

module Wakanow
  def soap
    url = load_config['sugar_url']
    wsdl = SOAP::WSDLDriverFactory.new(url)
    so = wsdl.create_rpc_driver
  end

  def logger
    Logger.new('wakanow.log')
  end

  def current_date
    Time.now.strftime("%d/%m/%Y")
  end

  def load_config
    @config = YAML.load_file File.expand_path("config.yml")
  end

  def file_in_dir_matching_month_to_a(module_name)
    results = []
    Dir.foreach(File.realdirpath('./data')) do |filename|
      if filename.index("#{module_name}.csv")
        results << "./data/#{filename}"
      end
    end
    results
  end
end

