require "ferrum_pdf/version"
require "ferrum_pdf/railtie"
require "ferrum"

module FerrumPdf
  DEFAULT_HEADER_TEMPLATE = "<div class='date text left'></div><div class='title text center'></div>"
  DEFAULT_FOOTER_TEMPLATE = <<~HTML
    <div class='url text left grow'></div>
    <div class='text right'><span class='pageNumber'></span>/<span class='totalPages'></span></div>
  HTML

  autoload :Controller, "ferrum_pdf/controller"
  autoload :HTMLPreprocessor, "ferrum_pdf/html_preprocessor"

  mattr_accessor :include_controller_module
  @@include_controller_module = true

  class << self
    def browser(**options)
      @browser ||= Ferrum::Browser.new(options)
    end

    def quit
      @browser&.quit
      @browser = nil
    end

    def render_pdf(html: nil, url: nil, host: nil, protocol: nil, authorize: nil, wait_for_idle_options: nil, pdf_options: {})
      render(host: host, protocol: protocol, html: html, url: url, authorize: authorize, wait_for_idle_options: wait_for_idle_options) do |page|
        page.pdf(**pdf_options.with_defaults(encoding: :binary))
      end
    end

    def render_screenshot(html: nil, url: nil, host: nil, protocol: nil, authorize: nil, screenshot_options: {})
      render(host: host, protocol: protocol, html: html, url: url, authorize: authorize) do |page|
        page.screenshot(**screenshot_options.with_defaults(encoding: :binary, full: true))
      end
    end

    def render(host:, protocol:, html: nil, url: nil, authorize: nil, wait_for_idle_options: nil)
      browser.create_page do |page|
        page.network.authorize(**authorize) { |req| req.continue } if authorize
        if html
          page.content = FerrumPdf::HTMLPreprocessor.process(html, host, protocol)
        else
          page.go_to(url)
        end
        page.network.wait_for_idle(**wait_for_idle_options)
        yield page
      ensure
        page.close
      end
    rescue Ferrum::DeadBrowserError
      retry
    end
  end
end
