require "test_helper"

class FerrumPdf::ConfigurationTest < ActiveSupport::TestCase
  setup do
    FerrumPdf.reset_configuration!
  end

  test "configuration can be set through configure method" do
    FerrumPdf.configure do |config|
      config.timeout = 30
      config.window_size = [ 1024, 768 ]
    end

    assert_equal 30, FerrumPdf.configuration.timeout
    assert_equal [ 1024, 768 ], FerrumPdf.configuration.window_size
  end

  test "configuration is used when creating browser" do
    FerrumPdf.configure do |config|
      config.timeout = 45
    end

    browser = FerrumPdf.browser
    assert_instance_of Ferrum::Browser, browser
    assert_equal 45, browser.instance_variable_get(:@options).timeout
  end

  test "changing configuration creates new browser instance" do
    FerrumPdf.configure do |config|
      config.timeout = 20
    end
    first_browser = FerrumPdf.browser

    FerrumPdf.configure do |config|
      config.timeout = 30
    end
    second_browser = FerrumPdf.browser

    assert_not_equal first_browser.object_id, second_browser.object_id
    assert_equal 20, first_browser.instance_variable_get(:@options).timeout
    assert_equal 30, second_browser.instance_variable_get(:@options).timeout
  end
end
