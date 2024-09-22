class PdfsController < ApplicationController
  def show
    respond_to do |format|
      format.html
      format.pdf {
        pdf = render_pdf(pdf_options: {
          display_header_footer: true,
          header_template: FerrumPdf::DEFAULT_HEADER_TEMPLATE,
          footer_template: FerrumPdf::DEFAULT_FOOTER_TEMPLATE
        })
        send_data pdf, disposition: :inline, filename: "test.pdf"
      }
    end
  end
end
