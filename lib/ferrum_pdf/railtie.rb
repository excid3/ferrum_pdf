module FerrumPdf
  class Railtie < ::Rails::Railtie
    initializer "ferrum_pdf.controller" do
      ActiveSupport.on_load(:action_controller) do
        # render ferrum_pdf: { pdf options }, template: "whatever", disposition: :inline, filename: "example.pdf"
        ActionController.add_renderer :ferrum_pdf do |pdf_options, options|
          send_data_options = options.extract!(:disposition, :filename, :status)
          url = pdf_options.delete(:url)
          html = render_to_string(**options.with_defaults(formats: [ :html ])) if url.blank?
          pdf = FerrumPdf.render_pdf(html: html, display_url: request.original_url, url: url, pdf_options: pdf_options)
          send_data(pdf, **send_data_options.with_defaults(type: :pdf))
        end

        # render ferrum_screenshot: { pdf options }, template: "whatever", disposition: :inline, filename: "example.png"
        ActionController.add_renderer :ferrum_screenshot do |screenshot_options, options|
          send_data_options = options.extract!(:disposition, :filename, :status)
          url = screenshot_options.delete(:url)
          html = render_to_string(**options.with_defaults(formats: [ :html ])) if url.blank?
          screenshot = FerrumPdf.render_screenshot(url: url, html: html, display_url: request.original_url, screenshot_options: screenshot_options)
          send_data(screenshot, **send_data_options.with_defaults(type: screenshot_options.fetch(:format, :png)))
        end
      end
    end
  end
end
