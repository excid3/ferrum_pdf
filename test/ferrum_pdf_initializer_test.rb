require "test_helper"

class FerrumPdfInitializerTest < ActiveSupport::TestCase
  test "initializer sets configuration" do
    # This assumes you have an initializer in your dummy app
    # If not, you'll need to add one (see step 4)
    assert_equal true, FerrumPdf.configuration[:headless]
    assert_equal 20, FerrumPdf.configuration[:timeout]
    assert_equal [ 1280, 800 ], FerrumPdf.configuration[:window_size]
  end
end
