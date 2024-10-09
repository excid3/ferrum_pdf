module FerrumPdf
  class Railtie < ::Rails::Railtie
    initializer "ferrum_pdf.controller" do
      ActiveSupport.on_load(:action_controller) do
        include FerrumPdf::Controller if FerrumPdf.include_controller_module
      end
    end

    initializer "ferrum_pdf.load_configuration" do
      config.after_initialize do
        FerrumPdf.configure do |config|
          # Load default configuration here if needed
        end
      end
    end
  end
end
