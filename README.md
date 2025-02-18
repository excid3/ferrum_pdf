# FerrumPdf

PDFs & screentshots for Rails using [Ferrum](https://github.com/rubycdp/ferrum) & headless Chrome.

Inspired by [Grover](https://github.com/Studiosity/grover).

## Installation

First, make sure Chrome is installed

Run the following or add the gem to your Gemfile:

```ruby
bundle add "ferrum_pdf"
```

## Configuration

You can configure FerrumPdf globally using an initializer. Create a file `config/initializers/ferrum_pdf.rb` in your Rails application:

```ruby
FerrumPdf.configure do |config|
  config.headless = true
  config.process_timeout = 30  # Time to wait for browser to start (in seconds)
  config.timeout = 10          # Default timeout for operations (in seconds)
  config.window_size = [1280, 800]
  # Add any other Ferrum options you want to set globally
end
```

These options will be used as default settings for all FerrumPdf operations. You can still override these settings on a per-use basis when calling `render_pdf` or `render_screenshot`.

## Usage

You can use FerrumPdf to render [PDFs](#-pdfs) and [Screenshots](#-screenshots)

### 📄 PDFs

There are two ways to render PDFs:

* [FerrumPdf.render_pdf](#render-pdfs)
* [render_pdf in Rails](#render-pdfs-from-rails-controllers)

#### Render PDFs from Rails controllers

Use the `render_pdf` helper in Rails controllers to render a PDF from the current action.

```ruby
def show
  respond_to do |format|
    format.html
    format.pdf {
      pdf = render_pdf()
      send_data pdf, disposition: :inline, filename: "example.pdf"
    }
  end
end
```

You can also customize which template is rendered. This will render the template to string with `render_to_string` in Rails, then pass it along to Chrome. For example, you can add headers and footers using `pdf_options` and use a specific layout:

```ruby
render_pdf(
  layout: "pdf,
  pdf_options: {
    display_header_footer: true,
    header_template: FerrumPdf::DEFAULT_HEADER_TEMPLATE,
    footer_template: FerrumPdf::DEFAULT_FOOTER_TEMPLATE
  }
)
```

#### Render PDFs

FerrumPdf can generate a PDF from HTML or a URL:

```ruby
FerrumPdf.render_pdf(html: content)
FerrumPdf.render_pdf(url: "https://google.com")
```

You can also pass host and protocol to convert any relative paths to full URLs. This is helpful for converting relative asset paths to full URLs.

```ruby
FerrumPdf.render_pdf(
  html: content, # Provide HTML
  url: "https://example.com", # or provide a URL to the content
  host: request.base_url + "/", # Used for setting the host for relative paths
  protocol: request.protocol, # Used for handling relative protocol paths
  authorize: { user: "username", password: "password" }, # Used for authenticating with basic auth
  wait_for_idle_options: { connections: 0, duration: 0.05, timeout: 5 }, # Used for setting network wait_for_idle options

  pdf_options: {
    landscape: false, # paper orientation
    scale: 1, # Scale of the webpage rendering
    format: nil,
    paper_width: 8.5, # Paper width in inches
    paper_height: 11, # Paper height in inches
    page_ranges: nil, # Paper ranges to print "1-5, 8 11-13"

    # Margins (in inches, defaults to 1cm)
    margin_top: 0.4,
    margin_bottom: 0.4,
    margin_left: 0.4,
    margin_right: 0.4,

    # Header, footer, and background options
    #
    # Variables can be used with CSS classes. For example <span class="date"></span>
    # * date: formatted print date
    # * title: document title
    # * url: document location
    # * pageNumber: current page number
    # *totalPages: total pages in the document

    display_header_footer: false,
    print_background: false, # Print background graphics
    header_template: "", # HTML template for the header
    footer_template: "", # HTML template for the footer
  }
)
```

See [Chrome DevTools Protocol docs](https://chromedevtools.github.io/devtools-protocol/tot/Page/#method-printToPDF) and [Ferrum's `#pdf` docs](https://github.com/rubycdp/ferrum?tab=readme-ov-file#pdfoptions--string--boolean) for the full set of options.

### 🎆 Screenshots

There are two ways to render Screenshots:

* [FerrumPdf.render_screenshot](#render-screenshots)
* [render_screenshot in Rails](#render-screenshots-from-rails-controllers)

#### Render Screenshots from Rails controllers

Use the `render_screenshot` helper in Rails controllers to render a PDF from the current action.

```ruby
def show
  respond_to do |format|
    format.html
    format.png {
      screenshot = render_screenshot()
      send_data screenshot, disposition: :inline, filename: "example.png"
    }
  end
end
```

You can also customize which template is rendered. This will render the template to string with `render_to_string` in Rails, then pass it along to Chrome.

```ruby
render_screenshot(
  screenshot_options: {
    format: "png" # or "jpeg"
    quality: nil # Integer 0-100 works for jpeg only
    full: true # Boolean whether you need full page screenshot or a viewport
    selector: nil # String css selector for given element, optional
    area: nil # Hash area for screenshot, optional. {x: 0, y: 0, width: 100, height: 100}
    scale: nil # Float zoom in/out
    background_color: nil # Ferrum::RGBA.new(0, 0, 0, 0.0)
  }
)
```

See [Ferrum screenshot docs](https://github.com/rubycdp/ferrum?tab=readme-ov-file#screenshotoptions--string--integer) for the full set of options.

#### Render Screenshots

FerrumPdf can generate a screenshot from HTML or a URL:

```ruby
FerrumPdf.render_screenshot(html: content)
FerrumPdf.render_screenshot(url: "https://google.com")
```

You can also pass host and protocol to convert any relative paths to full URLs. This is helpful for converting relative asset paths to full URLs.

```ruby
FerrumPdf.render_screenshot(
  html: "",
  url: "",
  root_url: "",
  protocol: "",
  screenshot_options: {
    format: "png" # or "jpeg"
    quality: nil # Integer 0-100 works for jpeg only
    full: true # Boolean whether you need full page screenshot or a viewport
    selector: nil # String css selector for given element, optional
    area: nil # Hash area for screenshot, optional. {x: 0, y: 0, width: 100, height: 100}
    scale: nil # Float zoom in/out
    background_color: nil # Ferrum::RGBA.new(0, 0, 0, 0.0)
  }
)
```

## Contributing

If you have an issue you'd like to submit, please do so using the issue tracker in GitHub. In order for us to help you in the best way possible, please be as detailed as you can.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
