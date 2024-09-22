class PdfsController < ApplicationController
  def index
  end

  def show
    respond_to do |format|
      format.html
      format.pdf {
        pdf = render_pdf(
          layout: "pdf",
          pdf_options: {
            display_header_footer: true,
            header_template: FerrumPdf::DEFAULT_HEADER_TEMPLATE,
            footer_template: FerrumPdf::DEFAULT_FOOTER_TEMPLATE
          }
        )
        send_data pdf, disposition: :inline, filename: "example.pdf"
      }
      format.png { send_data render_screenshot, disposition: :inline, filename: "example.png" }
    end
  end

  def url
    respond_to do |format|
      format.pdf {
        pdf = FerrumPdf.render_pdf(url: params[:url])
        send_data pdf, disposition: :inline, filename: "example.pdf"
      }
      format.png {
        screenshot = FerrumPdf.render_screenshot(url: params[:url], screenshot_options: { full: params[:full] })
        send_data screenshot, disposition: :inline, filename: "example.png"
      }
    end
  end
end
