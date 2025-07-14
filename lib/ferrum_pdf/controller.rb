module FerrumPdf
  module Controller
    extend ActiveSupport::Concern

    def render_pdf(pdf_options: {}, **rendering, &block)
      content = render_to_string(**rendering.with_defaults(formats: [ :html ]))

      FerrumPdf.render_pdf(
        html: content,
        base_url: request.base_url,
        pdf_options: pdf_options,
        &block
      )
    end

    def render_screenshot(screenshot_options: {}, **rendering, &block)
      content = render_to_string(**rendering.with_defaults(formats: [ :html ]))

      FerrumPdf.render_screenshot(
        html: content,
        base_url: request.base_url,
        screenshot_options: screenshot_options,
        &block
      )
    end
  end
end
