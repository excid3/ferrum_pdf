require "test_helper"

class FerrumPdfInitializerTest < ActiveSupport::TestCase
  test "initializer sets configuration" do
    # This test checks the configuration set by the initializer in the dummy app
    assert_equal true, FerrumPdf.configuration[:headless]
    assert_equal 20, FerrumPdf.configuration[:timeout]
    assert_equal [ 1280, 800 ], FerrumPdf.configuration[:window_size]
  end
end
