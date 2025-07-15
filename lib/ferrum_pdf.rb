require "ferrum_pdf/version"
require "ferrum_pdf/railtie"
require "ferrum"

module FerrumPdf
  DEFAULT_HEADER_TEMPLATE = "<div class='date text left'></div><div class='title text center'></div>"
  DEFAULT_FOOTER_TEMPLATE = <<~HTML
    <div class='url text left grow'></div>
    <div class='text right'><span class='pageNumber'></span>/<span class='totalPages'></span></div>
  HTML

  autoload :AssetsHelper, "ferrum_pdf/assets_helper"
  autoload :Controller, "ferrum_pdf/controller"
  autoload :HTMLPreprocessor, "ferrum_pdf/html_preprocessor"

  mattr_accessor :include_assets_helper_module, default: true
  mattr_accessor :include_controller_module, default: true
  mattr_accessor :browsers, default: {}
  mattr_accessor :config, default: ActiveSupport::OrderedOptions.new.merge(
    window_size: [ 1920, 1080 ]
  )

  class << self
    def configure
      yield config
    end

    # Creates and registers a new browser for exports
    # If a browser with the same name already exists, it will be shut down before instantiating the new one
    def add_browser(name, **options)
      @@browsers[name].quit if @@browsers[name]
      @@browsers[name] = Ferrum::Browser.new(@@config.merge(options))
    end

    # Renders HTML or URL to PDF
    #
    #   render_pdf(url: "https://example.org/receipts/example.pdf")
    #   render_pdf(html: "<h1>Hello world</h1>")
    #
    # For rendering HTML, we also need the base_url for preprocessing URLs with relative paths & protocols
    #
    #   render_pdf(html: "<h1>Hello world</h1>", base_url: "https://example.org/")
    #
    def render_pdf(pdf_options: {}, **load_page_args)
      load_page(**load_page_args) do |browser, page|
        yield browser, page if block_given?
        page.pdf(**pdf_options.with_defaults(encoding: :binary))
      end
    end

    # Renders HTML or URL to Screenshot
    #
    # render_screenshot(url: "https://example.org/receipts/example.pdf")
    # render_screenshot(html: "<h1>Hello world</h1>")
    #
    # For rendering HTML, we also need the base_url for preprocessing URLs with relative paths & protocols
    #
    #   render_screenshot(html: "<h1>Hello world</h1>", base_url: "https://example.org/")
    #
    def render_screenshot(screenshot_options: {}, **load_page_args)
      load_page(**load_page_args) do |browser, page|
        yield browser, page if block_given?
        page.screenshot(**screenshot_options.with_defaults(encoding: :binary, full: true))
      end
    end

    # Loads page into the browser to be used for rendering PDFs or screenshots
    #
    # This automatically applies HTML preprocessing if `html:` is present
    #
    def load_page(url: nil, html: nil, base_url: nil, authorize: nil, wait_for_idle_options: nil, browser: :default, retries: 1)
      try = 0

      # Lookup browser if a name was passed
      browser = @@browsers[browser] || add_browser(browser) if browser.is_a? Symbol

      # Automatically restart the browser if it was disconnected
      browser.restart unless browser.client.present?

      # Closes page automatically after block finishes
      # https://github.com/rubycdp/ferrum/blob/main/lib/ferrum/browser.rb#L169
      browser.create_page do |page|
        page.network.authorize(**authorize) { |req| req.continue } if authorize

        # Load content
        if html
          page.content = FerrumPdf::HTMLPreprocessor.process(html, base_url)
        else
          page.go_to(url)
        end

        # Wait for everything to load
        page.network.wait_for_idle(**wait_for_idle_options)

        yield browser, page
      end
    rescue Ferrum::DeadBrowserError
      try += 1
      if try <= retries
        browser.restart
        retry
      else
        raise
      end
    end
  end
end
