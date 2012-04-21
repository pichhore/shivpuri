 require 'pdfkit'
 PDFKit.configure do |config|
#      config.wkhtmltopdf = RAILS_ROOT.to_s + "/bin/wkhtmltopdf1"
  config.wkhtmltopdf = RAILS_ROOT.to_s + "/bin/wkhtmltopdf-amd64"
 end

