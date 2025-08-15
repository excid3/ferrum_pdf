require "test_helper"
require "ostruct"

class FerrumPdfAssetsHelperTest < ActiveSupport::TestCase
  include FerrumPdf::AssetsHelper

  class FakeAsset
    attr_reader :content_type, :content, :source

    def initialize(content_type:, content: nil, source: nil)
      @content_type = content_type
      @content = content
      @source = source
    end
  end

  setup do
    @original_assets = Rails.application.assets
  end

  teardown do
    Rails.application.instance_variable_set(:@assets, @original_assets)
  end

  def stub_assets_with_propshaft(asset)
    fake_load_path = Object.new
    def fake_load_path.find(path)
      @asset if path == "styles.css"
    end
    fake_load_path.instance_variable_set(:@asset, asset)

    fake_assets = Object.new
    def fake_assets.respond_to?(method, _include_all = false)
      method == :load_path || super
    end
    fake_assets.define_singleton_method(:load_path) { fake_load_path }

    Rails.application.instance_variable_set(:@assets, fake_assets)
  end

  def stub_assets_with_sprockets(asset)
    fake_assets = Object.new
    def fake_assets.respond_to?(method, _include_all = false)
      method == :find_asset || super
    end
    fake_assets.define_singleton_method(:find_asset) do |path|
      asset if path == "app.js"
    end

    Rails.application.instance_variable_set(:@assets, fake_assets)
  end

  test "propshaft asset is found and wrapped correctly" do
    asset = FakeAsset.new(content_type: :css, content: "body { color: red; }")
    stub_assets_with_propshaft(asset)

    found = FerrumPdf::AssetFinder.find("styles.css")
    assert_instance_of FerrumPdf::PropshaftAsset, found
    assert_equal "css", found.content_type
    assert_equal "body { color: red; }", found.content
  end

  test "sprockets asset is found and wrapped correctly" do
    asset = FakeAsset.new(content_type: "application/javascript", source: "console.log('hi');")
    stub_assets_with_sprockets(asset)

    found = FerrumPdf::AssetFinder.find("app.js")
    assert_instance_of FerrumPdf::SprocketsAsset, found
    assert_equal "application/javascript", found.content_type
    assert_equal "console.log('hi');", found.content
  end

  test "find returns nil when asset not found" do
    stub_assets_with_propshaft(nil)
    assert_nil FerrumPdf::AssetFinder.find("missing.css")

    stub_assets_with_sprockets(nil)
    assert_nil FerrumPdf::AssetFinder.find("missing.js")
  end

  test "ferrum_pdf_inline_stylesheet returns inline style tag" do
    asset = FakeAsset.new(content_type: :css, content: "h1 { font-size: 20px; }")
    stub_assets_with_propshaft(asset)

    html = ferrum_pdf_inline_stylesheet("styles.css")
    assert_equal "<style>h1 { font-size: 20px; }</style>", html
  end

  test "ferrum_pdf_inline_javascript returns inline script tag" do
    asset = FakeAsset.new(content_type: "application/javascript", source: "alert('hi');")
    stub_assets_with_sprockets(asset)

    html = ferrum_pdf_inline_javascript("app.js")
    assert_equal "<script>alert('hi');</script>", html
  end

  test "ferrum_pdf_base64_asset returns correct base64 string" do
    content = "body { background: black; }"
    asset = FakeAsset.new(content_type: "text/css", content: content)
    stub_assets_with_propshaft(asset)

    base64 = ferrum_pdf_base64_asset("styles.css")
    expected_prefix = "data:text/css;base64,"
    assert base64.start_with?(expected_prefix)
    decoded = Base64.decode64(base64.delete_prefix(expected_prefix))
    assert_equal content, decoded
  end

  test "helper methods return nil when asset not found" do
    stub_assets_with_propshaft(nil)
    assert_nil ferrum_pdf_inline_stylesheet("missing.css")
    assert_nil ferrum_pdf_inline_javascript("missing.js")
    assert_nil ferrum_pdf_base64_asset("missing.css")
  end
end
