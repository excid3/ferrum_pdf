require "test_helper"

class FerrumPdfTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert FerrumPdf::VERSION
  end

  test "re-registering browser shuts down previous browser" do
    first_browser = FerrumPdf.add_browser :example
    first_pid = first_browser.process.pid

    second_browser = FerrumPdf.add_browser :example
    second_pid = second_browser.process.pid

    # First browser should be shut down
    assert_nil first_browser.process

    # Second browser should have a different Process ID
    assert_not_equal first_pid, second_pid
  end
end
