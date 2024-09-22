module FerrumPdf
  class Railtie < ::Rails::Railtie
    initializer "ferrum_pdf.controller" do
      ActiveSupport.on_load(:action_controller) do
        include FerrumPdf::Controller if FerrumPdf.include_controller_module
      end
    end
  end
end
