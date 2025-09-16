module FerrumPdf
  # Helper module for preparing HTML for conversion
  #
  # Sourced from the PDFKit project
  # @see https://github.com/pdfkit/pdfkit
  module HTMLPreprocessor
    # Change root relative and page relative paths to absolute, and relative protocols to absolute protocols
    #
    #   process("Some HTML", "https://example.org")
    #
    def self.process(html, base_url)
      return html if base_url.blank?

      base_url += "/" unless base_url.end_with? "/"
      uri = URI(base_url)
      port_part = uri.port && ![80, 443].include?(uri.port) ? ":#{uri.port}" : ""
      root_url  = "#{uri.scheme}://#{uri.host}#{port_part}/"
      protocol = uri.scheme

      html = translate_root_relative_paths(html, root_url) if root_url
      html = translate_page_relative_paths(html, base_url) if base_url
      html = translate_relative_protocols(html, protocol) if protocol
      html
    end

    def self.translate_root_relative_paths(html, root_url)
      # Try out this regexp using rubular https://rubular.com/r/3624VOEgG5atZn
      html.gsub(%r{(href|src)=(['"])/(?!/)([^/"']([^"']*|[^"']*))?['"]}, "\\1=\\2#{root_url}\\3\\2")
    end
    private_class_method :translate_root_relative_paths

    def self.translate_page_relative_paths(html, base_url)
      # Try out this regexp using rubular https://rubular.com/r/axnIqShzHu6sLs
      html.gsub(%r{(href|src)=(['"])(?!/|[a-zA-Z][a-zA-Z0-9+\-.]*:)([^/"']([^"']*|[^"']*))?['"]}, "\\1=\\2#{base_url}\\3\\2")
    end
    private_class_method :translate_page_relative_paths

    def self.translate_relative_protocols(body, protocol)
      # Try out this regexp using rubular http://rubular.com/r/0Ohk0wFYxV
      body.gsub(%r{(href|src)=(['"])//([^"']*|[^"']*)['"]}, "\\1=\\2#{protocol}://\\3\\2")
    end
    private_class_method :translate_relative_protocols
  end
end
