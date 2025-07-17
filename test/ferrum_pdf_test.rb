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
end
