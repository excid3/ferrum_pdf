require "test_helper"

class HtmlPreProcessingTest< ActiveSupport::TestCase
  test "does nothing when no relative protocols or urls are found" do
    assert_equal "<h1>Hello</h1>", FerrumPdf::HTMLPreprocessor.process("<h1>Hello</h1>", "https://example.org")
  end

  test "replaces relative paths" do
    assert_equal "<a href=\"http://example.org/example.pdf\">PDF</a>", FerrumPdf::HTMLPreprocessor.process("<a href=\"/example.pdf\">PDF</a>", "http://example.org")
    assert_equal "<a href=\"https://example.com/example.pdf\">PDF</a>", FerrumPdf::HTMLPreprocessor.process("<a href=\"/example.pdf\">PDF</a>", "https://example.com")
  end

  test "replaces relative protocols" do
    assert_equal "<a href=\"http://domain.com/example.pdf\">PDF</a>", FerrumPdf::HTMLPreprocessor.process("<a href=\"//domain.com/example.pdf\">PDF</a>", "http://example.org")
    assert_equal "<a href=\"https://domain.com/example.pdf\">PDF</a>", FerrumPdf::HTMLPreprocessor.process("<a href=\"//domain.com/example.pdf\">PDF</a>", "https://example.com")
  end
end
