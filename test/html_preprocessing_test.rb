require "test_helper"

class HtmlPreProcessingTest< ActiveSupport::TestCase
  test "does nothing when no relative protocols or urls are found" do
    assert_equal "<h1>Hello</h1>", FerrumPdf::HTMLPreprocessor.process("<h1>Hello</h1>", "https://example.org")
  end

  test "does not raise error when url absent" do
    assert_equal "<a href=\"/example.pdf\">PDF</a>", FerrumPdf::HTMLPreprocessor.process("<a href=\"/example.pdf\">PDF</a>", nil)
    assert_equal "<a href=\"/example.pdf\">PDF</a>", FerrumPdf::HTMLPreprocessor.process("<a href=\"/example.pdf\">PDF</a>", "")
  end

  test "replaces root-relative paths with root url" do
    base_url = "https://example.com/some/deep/path"
    input = "<a href=\"/example.pdf\">PDF</a><img src=\"/assets/app.png\">"
    output = FerrumPdf::HTMLPreprocessor.process(input, base_url)

    assert_includes output, "href=\"https://example.com/example.pdf\""
    assert_includes output, "src=\"https://example.com/assets/app.png\""
  end

  test "replaces page-relative paths with base url" do
    base_url = "https://example.com/some/deep/path/"
    input = "<a href=\"docs/example.pdf\">PDF</a><script src=\"js/app.js\"></script>"
    output = FerrumPdf::HTMLPreprocessor.process(input, base_url)

    assert_includes output, "href=\"https://example.com/some/deep/path/docs/example.pdf\""
    assert_includes output, "src=\"https://example.com/some/deep/path/js/app.js\""
  end

  test "replaces relative protocols" do
    assert_equal "<a href=\"http://domain.com/example.pdf\">PDF</a>", FerrumPdf::HTMLPreprocessor.process("<a href=\"//domain.com/example.pdf\">PDF</a>", "http://example.org")
    assert_equal "<a href=\"https://domain.com/example.pdf\">PDF</a>", FerrumPdf::HTMLPreprocessor.process("<a href=\"//domain.com/example.pdf\">PDF</a>", "https://example.com")
  end

  test "does not rewrite absolute, mailto, or data URLs" do
    base_url = "https://example.com/base/"
    input = "<a href=\"https://other.com/file.pdf\">abs</a><a href=\"mailto:test@example.com\">mail</a><img src=\"data:image/png;base64,AAA\">"
    output = FerrumPdf::HTMLPreprocessor.process(input, base_url)

    assert_includes output, "href=\"https://other.com/file.pdf\""
    assert_includes output, "href=\"mailto:test@example.com\""
    assert_includes output, "src=\"data:image/png;base64,AAA\""
  end
end
