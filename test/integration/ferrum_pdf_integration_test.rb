require "test_helper"

class FerrumPdfIntegrationTest < ActionDispatch::IntegrationTest
  test "can generate a PDF" do
    get "/pdfs/show.pdf"
    assert_response :success
    assert_equal "application/pdf", response.content_type
    assert_includes response.headers["Content-Disposition"], "inline"
    assert_includes response.headers["Content-Disposition"], 'filename="example.pdf"'
  end

  test "can generate a PNG screenshot" do
    get "/pdfs/show.png"
    assert_response :success
    assert_equal "image/png", response.content_type
    assert_includes response.headers["Content-Disposition"], "inline"
    assert_includes response.headers["Content-Disposition"], 'filename="example.png"'
  end

  test "can generate a PDF from URL" do
    get "/pdfs/url.pdf", params: { url: "https://google.com" }
    assert_response :success
    assert_equal "application/pdf", response.content_type
    assert_includes response.headers["Content-Disposition"], "inline"
    assert_includes response.headers["Content-Disposition"], 'filename="example.pdf"'
  end

  test "can generate a PNG screenshot from URL" do
    get "/pdfs/url.png", params: { url: "https://google.com" }
    assert_response :success
    assert_equal "image/png", response.content_type
    assert_includes response.headers["Content-Disposition"], "inline"
    assert_includes response.headers["Content-Disposition"], 'filename="example.png"'
  end
end
