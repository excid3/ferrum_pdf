require "ferrum_pdf/version"
require "ferrum_pdf/railtie"

require "ferrum"

module FerrumPdf
  DEFAULT_HEADER_TEMPLATE = "<div class='date text left'></div><div class='title text center'></div>"
  DEFAULT_FOOTER_TEMPLATE = <<~HTML
    <div class='url text left grow'></div>
    <div class='text right'><span class='pageNumber'></span>/<span class='totalPages'></span></div>
  HTML

  def self.browser(**options)
    @browser ||= Ferrum::Browser.new(options)
  end

  def self.render_pdf(host:, protocol:, html: nil, url: nil, pdf_options: {})
    browser.create_page do |page|
      if html
        page.content = FerrumPdf::HTMLPreprocessor.process(html, host, protocol)
        page.network.wait_for_idle
      else
        page.go_to(url)
      end
      page.pdf(**pdf_options.with_defaults(encoding: :binary))
    end
  end

  # Helper module for preparing HTML for conversion
  #
  # Sourced from the PDFKit project
  # @see https://github.com/pdfkit/pdfkit
  module HTMLPreprocessor
    # Change relative paths to absolute, and relative protocols to absolute protocols
    def self.process(html, root_url, protocol)
      html = translate_relative_paths(html, root_url) if root_url
      html = translate_relative_protocols(html, protocol) if protocol
      html
    end

    def self.translate_relative_paths(html, root_url)
      # Try out this regexp using rubular http://rubular.com/r/hiAxBNX7KE
      html.gsub(%r{(href|src)=(['"])/([^/"']([^"']*|[^"']*))?['"]}, "\\1=\\2#{root_url}\\3\\2")
    end
    private_class_method :translate_relative_paths

    def self.translate_relative_protocols(body, protocol)
      # Try out this regexp using rubular http://rubular.com/r/0Ohk0wFYxV
      body.gsub(%r{(href|src)=(['"])//([^"']*|[^"']*)['"]}, "\\1=\\2#{protocol}://\\3\\2")
    end
    private_class_method :translate_relative_protocols
  end

  module Controller
    extend ActiveSupport::Concern

    def render_pdf(name = action_name, formats: [ :html ], pdf_options: {})
      content = render_to_string(name, formats: formats)

      FerrumPdf.render_pdf(
        html: content,
        host: request.host_with_port,
        protocol: request.protocol,
        pdf_options: pdf_options
      )
    end
  end
end
