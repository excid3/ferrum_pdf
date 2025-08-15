module FerrumPdf
  class BaseAsset
    def initialize(asset)
      @asset = asset
    end
  end

  class PropshaftAsset < BaseAsset
    def content_type
      @asset.content_type.to_s
    end

    def content
      @asset.content
    end
  end

  class SprocketsAsset < BaseAsset
    def content_type
      @asset.content_type
    end

    def content
      @asset.source
    end
  end

  class AssetFinder
    class << self
      def find(path, assets: Rails.application.assets)
        if assets.respond_to?(:load_path)
          propshaft_asset(assets.load_path.find(path))
        elsif assets.respond_to?(:find_asset)
          sprockets_asset(assets.find_asset(path))
        end
      end

      private

      def propshaft_asset(asset)
        asset && PropshaftAsset.new(asset)
      end

      def sprockets_asset(asset)
        asset && SprocketsAsset.new(asset)
      end
    end
  end

  module AssetsHelper
    def ferrum_pdf_inline_stylesheet(path)
      inline_ferrum_pdf_tag path, "style"
    end

    def ferrum_pdf_inline_javascript(path)
      inline_ferrum_pdf_tag path, "script"
    end

    def ferrum_pdf_base64_asset(path)
      return nil unless (asset = AssetFinder.find(path))

      "data:#{asset.content_type};base64,#{Base64.encode64(asset.content).gsub(/\s+/, '')}"
    end

    private

    def inline_ferrum_pdf_tag(path, tag)
      (asset = AssetFinder.find(path)) && "<#{tag}>#{asset.content}</#{tag}>".html_safe
    end
  end
end
