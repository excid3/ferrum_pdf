module FerrumPdf
  class Railtie < ::Rails::Railtie
    initializer "ferrum_pdf.assets_helper" do
      ActiveSupport.on_load(:action_view) do
        include FerrumPdf::AssetsHelper if FerrumPdf.include_assets_helper_module
      end
    end

    initializer "ferrum_pdf.controller" do
      ActiveSupport.on_load(:action_controller) do
        include FerrumPdf::Controller if FerrumPdf.include_controller_module
      end
    end
  end
end
