module FerrumPdf
  # Helper module for preparing HTML for conversion
  #
  # Sourced from the PDFKit project
  # @see https://github.com/pdfkit/pdfkit
  module HTMLPreprocessor
    # Change relative paths to absolute, and relative protocols to absolute protocols
    #
    #   process("Some HTML", "https://example.org")
    #
    def self.process(html, base_url)
      base_url += "/" unless base_url.end_with? "/"
      protocol = base_url.split("://").first
      html = translate_relative_paths(html, base_url) if base_url
      html = translate_relative_protocols(html, protocol) if protocol
      html
    end

    def self.translate_relative_paths(html, base_url)
      # Try out this regexp using rubular http://rubular.com/r/hiAxBNX7KE
      html.gsub(%r{(href|src)=(['"])/([^/"']([^"']*|[^"']*))?['"]}, "\\1=\\2#{base_url}\\3\\2")
    end
    private_class_method :translate_relative_paths

    def self.translate_relative_protocols(body, protocol)
      # Try out this regexp using rubular http://rubular.com/r/0Ohk0wFYxV
      body.gsub(%r{(href|src)=(['"])//([^"']*|[^"']*)['"]}, "\\1=\\2#{protocol}://\\3\\2")
    end
    private_class_method :translate_relative_protocols
  end
end
