require "test_helper"

class FerrumPdf::ConfigurationTest < ActiveSupport::TestCase
  def setup
    FerrumPdf.reset_configuration!
  end

  test "configuration can be set through initializer" do
    FerrumPdf.configure do |config|
      config[:headless] = true
      config[:timeout] = 30
      config[:window_size] = [ 1024, 768 ]
    end

    assert_equal true, FerrumPdf.configuration[:headless]
    assert_equal 30, FerrumPdf.configuration[:timeout]
    assert_equal [ 1024, 768 ], FerrumPdf.configuration[:window_size]
  end

  test "configuration is used when creating browser" do
    FerrumPdf.configure do |config|
      config[:headless] = false
      config[:timeout] = 45
    end

    browser = FerrumPdf.browser
    assert_instance_of Ferrum::Browser, browser
    browser_options = browser.instance_variable_get(:@options)
    assert_equal false, browser_options.headless
    assert_equal 45, browser_options.timeout
  end

  test "default configuration is empty" do
    assert_empty FerrumPdf.configuration
  end
end