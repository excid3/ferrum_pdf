module FerrumPdf
  module Controller
    extend ActiveSupport::Concern

    def render_pdf(pdf_options: {}, **rendering)
      content = render_to_string(**rendering.with_defaults(formats: [ :html ]))

      FerrumPdf.render_pdf(
        html: content,
        host: request.base_url + "/",
        protocol: request.protocol,
        pdf_options: pdf_options
      )
    end

    def render_screenshot(screenshot_options: {}, **rendering)
      content = render_to_string(**rendering.with_defaults(formats: [ :html ]))

      FerrumPdf.render_screenshot(
        html: content,
        host: request.base_url + "/",
        protocol: request.protocol,
        screenshot_options: screenshot_options
      )
    end
  end
end
