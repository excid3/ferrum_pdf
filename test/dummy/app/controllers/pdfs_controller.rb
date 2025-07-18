class PdfsController < ApplicationController
  def index
  end

  def show
    respond_to do |format|
      format.html
      format.pdf {
        render ferrum_pdf: {
            display_header_footer: true,
            header_template: FerrumPdf::DEFAULT_HEADER_TEMPLATE,
            footer_template: FerrumPdf::DEFAULT_FOOTER_TEMPLATE
        },
        disposition: :inline,
        filename: "example.pdf"
      }
      format.png { render ferrum_screenshot: {}, disposition: :inline, filename: "example.png" }
    end
  end

  def url
    respond_to do |format|
      format.pdf { render ferrum_pdf: { url: params[:url] }, disposition: :inline, filename: "example.pdf" }
      format.png { render ferrum_screenshot: { url: params[:url], full: params[:full] }, disposition: :inline, filename: "example.png" }
    end
  end
end
