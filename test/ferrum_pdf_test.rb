require "test_helper"

class FerrumPdfTest < ActiveSupport::TestCase
  def teardown
    # Reset browser state after each test to avoid flaky behavior
    FerrumPdf.browser = nil
  end

  test "it has a version number" do
    assert FerrumPdf::VERSION
  end

  test "setting new browser replaces previous browser" do
    first_browser = Ferrum::Browser.new
    first_pid = first_browser.process.pid
    FerrumPdf.browser = first_browser

    second_browser = Ferrum::Browser.new
    second_pid = second_browser.process.pid
    FerrumPdf.browser = second_browser

    # First browser should be shut down
    assert_nil first_browser.process

    # Second browser should have a different Process ID
    assert_not_equal first_pid, second_pid

    FerrumPdf.with_browser do |yielded_browser|
      assert_same second_browser, yielded_browser
    end
  end

  test "auto-creates browser when none is set" do
    FerrumPdf.browser = nil

    FerrumPdf.with_browser do |browser|
      assert_instance_of Ferrum::Browser, browser
      assert browser.client.present?
    end
  end

  test "auto-created browser uses config settings" do
    original_config = FerrumPdf.config.dup
    FerrumPdf.config.window_size = [ 800, 600 ]

    FerrumPdf.browser = nil

    FerrumPdf.with_browser do |browser|
      assert_instance_of Ferrum::Browser, browser
      assert_equal [ 800, 600 ], browser.options.window_size
    end
  ensure
    FerrumPdf.config.replace(original_config)
  end

  test "reuses same browser instance across multiple with_browser calls" do
    FerrumPdf.browser = nil

    first_call_browser = nil
    second_call_browser = nil

    FerrumPdf.with_browser { |browser| first_call_browser = browser }
    FerrumPdf.with_browser { |browser| second_call_browser = browser }

    assert_same first_call_browser, second_call_browser
  end

  test "replaces a browser whose contexts were never built" do
    browser = Ferrum::Browser.new
    pid = browser.process.pid
    browser.instance_variable_set(:@contexts, nil)
    FerrumPdf.browser = browser

    FerrumPdf.with_browser do |yielded|
      assert_not_same browser, yielded
      assert_not_nil yielded.contexts
      assert_not_equal pid, yielded.process.pid
    end

    assert_nil browser.process.pid
  end

  test "uses different browser when provided" do
    FerrumPdf.browser = nil

    first_call_browser = nil
    second_call_browser = nil

    FerrumPdf.with_browser(Ferrum::Browser.new) { |browser| first_call_browser = browser }
    FerrumPdf.with_browser { |browser| second_call_browser = browser }

    assert_not_same first_call_browser, second_call_browser
  end

  test "falls back to the reserved display_url when none is given" do
    FerrumPdf.render_pdf(html: "<h1>Hello world</h1>") do |_browser, page|
      # Chrome normalizes a bare host by appending a trailing slash
      assert_equal "#{FerrumPdf::DEFAULT_DISPLAY_URL}/", page.url
    end
  end

  test "uses display_url from config when none is given" do
    FerrumPdf.config.page_options.display_url = "http://configured.invalid/reports"

    FerrumPdf.render_pdf(html: "<h1>Hello world</h1>") do |_browser, page|
      assert_equal "http://configured.invalid/reports", page.url
    end
  ensure
    FerrumPdf.config.page_options.delete(:display_url)
  end

  test "explicit display_url takes precedence over config" do
    FerrumPdf.config.page_options.display_url = "http://configured.invalid/reports"

    FerrumPdf.render_pdf(html: "<h1>Hello world</h1>", display_url: "http://explicit.invalid/page") do |_browser, page|
      assert_equal "http://explicit.invalid/page", page.url
    end
  ensure
    FerrumPdf.config.page_options.delete(:display_url)
  end

  test "renders HTML with relative assets and no display_url" do
    html = <<~HTML
      <html>
        <head><link rel="stylesheet" href="/assets/app.css"></head>
        <body><h1>Hello world</h1><img src="/assets/logo.png"></body>
      </html>
    HTML

    # Unresolvable asset requests must fail fast on DNS. If they hang instead,
    # #go_to raises Ferrum::PendingConnectionsError and no PDF comes back.
    assert FerrumPdf.render_pdf(html: html).start_with?("%PDF")
  end
end
