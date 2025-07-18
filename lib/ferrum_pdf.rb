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
  autoload :HTMLPreprocessor, "ferrum_pdf/html_preprocessor"

  mattr_accessor :browser_mutex, default: Mutex.new
  mattr_accessor :config, default: ActiveSupport::OrderedOptions.new.merge(
    window_size: [ 1920, 1080 ]
  )

  # This doesn't use mattr_accessor because having a `.browser` getter and also
  # having local variables named `browser` would be confusing. For simplicity,
  # this is explicitly accessed.
  @@browser = nil

  class << self
    def configure
      yield config
    end

    # Sets the browser instance to use for all operations
    # If a browser is already set, it will be shut down before setting the new one
    def browser=(browser_instance)
      browser_mutex.synchronize do
        @@browser&.quit
        @@browser = browser_instance
      end
    end

    # Provides thread-safe access to the browser instance
    def with_browser(browser = nil)
      if browser
        yield browser
      else
        browser_mutex.synchronize do
          @@browser ||= Ferrum::Browser.new(config)
          @@browser.restart unless @@browser.client.present?
          yield @@browser
        end
      end
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
    def load_page(url: nil, html: nil, base_url: nil, authorize: nil, wait_for_idle_options: nil, browser: nil, retries: 1)
      try = 0
      wait_for_idle_options ||= {}

      with_browser(browser) do |browser|
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
      end
    rescue Ferrum::DeadBrowserError
      try += 1
      if try <= retries
        with_browser(&:restart)
        retry
      else
        raise
      end
    end
  end
end
