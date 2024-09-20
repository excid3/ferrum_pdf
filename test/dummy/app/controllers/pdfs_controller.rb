class PdfsController < ApplicationController
  def show
    respond_to do |format|
      format.html
      format.pdf {
        send_data render_pdf, disposition: :inline, filename: "test.pdf"
      }
    end
  end
end
