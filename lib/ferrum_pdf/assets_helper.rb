module FerrumPdf
  module AssetsHelper
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
        def find(path)
          if Rails.application.assets.respond_to?(:load_path)
            propshaft_asset(path)
          elsif Rails.application.assets.respond_to?(:find_asset)
            sprockets_asset(path)
          else
            nil
          end
        end

        def propshaft_asset(path)
          (asset = Rails.application.assets.load_path.find(path)) ? PropshaftAsset.new(asset) : nil
        end

        def sprockets_asset(path)
          (asset = Rails.application.assets.find_asset(path)) ? SprocketsAsset.new(asset) : nil
        end
      end
    end

    def ferrum_pdf_inline_stylesheet(path)
      (asset = AssetFinder.find(path)) ? "<style>#{asset.content}</style>".html_safe : nil
    end

    def ferrum_pdf_inline_javascript(path)
      (asset = AssetFinder.find(path)) ? "<script>#{asset.content}</script>".html_safe : nil
    end

    def ferrum_pdf_base64_asset(path)
      return nil unless (asset = AssetFinder.find(path))

      "data:#{asset.content_type};base64,#{Base64.encode64(asset.content).gsub(/\s+/, '')}"
    end
  end
end
