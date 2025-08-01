# 📄 FerrumPdf

PDFs & screentshots for Rails using [Ferrum](https://github.com/rubycdp/ferrum) & headless Chrome.

Inspired by [Grover](https://github.com/Studiosity/grover), but without the Node.js and puppeteer dependencies. 🎉

## Installation

First, make sure Chrome is installed. Then run the following or add the gem to your Gemfile:

```ruby
bundle add "ferrum_pdf"
```

## Usage

You can use FerrumPdf to render [PDFs](#-pdfs) and [Screenshots](#-screenshots)

### 📄 PDFs

There are two ways to render PDFs:

* [`render ferrum_pdf: {}` in Rails](#render-pdfs-from-rails-controllers)
* [FerrumPdf.render_pdf](#render-pdfs)

#### Render PDFs from Rails controllers

Use the `ferrum_pdf` renderer in Rails controllers to render a PDF from the current action.

```ruby
def show
  respond_to do |format|
    format.html
    format.pdf { render ferrum_pdf: {}, disposition: :inline, filename: "example.pdf" }
  end
end
```

You can also customize which template is rendered. This will render the template to string with `render_to_string` in Rails, then pass it along to Chrome. For example, you can add headers and footers using `pdf_options` and use a specific layout:

```ruby
render ferrum_pdf: {
    display_header_footer: true,
    header_template: FerrumPdf::DEFAULT_HEADER_TEMPLATE,
    footer_template: FerrumPdf::DEFAULT_FOOTER_TEMPLATE
  },
  layout: "pdf",
  template: "pdf",
  disposition: :inline,
  filename: "example.pdf"
```

#### Render PDFs

FerrumPdf can generate a PDF from HTML or a URL:

```ruby
FerrumPdf.render_pdf(html: content)
FerrumPdf.render_pdf(url: "https://google.com")
```

The full list of options:

```ruby
FerrumPdf.render_pdf(
  url: "https://example.com/page", # Provide a URL to the content

  html: content, # or provide HTML
  base_url: request.base_url, # Preprocesses `html` to convert relative paths and protocols. Example: "https://example.org"

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

* [`render ferrum_screenshot: {}` in Rails](#render-screenshots-from-rails-controllers)
* [FerrumPdf.render_screenshot](#render-screenshots)

#### Render Screenshots from Rails controllers

Use the `ferrum_screenshot` renderer in Rails controllers to render a PDF from the current action.

```ruby
def show
  respond_to do |format|
    format.html
    format.png { render ferrum_screenshot: {}, disposition: :inline, filename: "example.png" }
  end
end
```

You can also customize which template is rendered. This will render the template to string with `render_to_string` in Rails, then pass it along to Chrome.

```ruby
render ferrum_screenshot: {
    format: "png" # or "jpeg"
    quality: nil # Integer 0-100 works for jpeg only
    full: true # Boolean whether you need full page screenshot or a viewport
    selector: nil # String css selector for given element, optional
    area: nil # Hash area for screenshot, optional. {x: 0, y: 0, width: 100, height: 100}
    scale: nil # Float zoom in/out
    background_color: nil # Ferrum::RGBA.new(0, 0, 0, 0.0)
  },
  layout: "example",
  template: "example"
  disposition: :inline,
  filename: "example.png"
```

See [Ferrum screenshot docs](https://github.com/rubycdp/ferrum?tab=readme-ov-file#screenshotoptions--string--integer) for the full set of options.

#### Render Screenshots

FerrumPdf can generate a screenshot from HTML or a URL:

```ruby
FerrumPdf.render_screenshot(html: content)
FerrumPdf.render_screenshot(url: "https://google.com")
```

The full list of options

```ruby
FerrumPdf.render_screenshot(
  url: "https://example.com/page", # Provide a URL to the content

  html: content, # or provide HTML
  base_url: request.base_url, # Preprocesses `html` to convert relative paths and protocols. Example: "https://example.org"

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

## Configuring the Browser

You can set the default browser options with the configure block.

See [Ferrum's Customization docs](https://github.com/rubycdp/ferrum?tab=readme-ov-file#customization) for a full list of options.

```ruby
FerrumPdf.configure do |config|
  config.window_size = [1920, 1080]

  # config.process_timeout = 30 # defaults to 10
  # config.browser_path = '/usr/bin/chromium'

  # For use with Docker, but ensure you trust any sites visited
  # config.browser_options = {
  #   "no-sandbox" => true
  # }
end
```

For Docker, `seccomp` is recommend over `--no-sandbox` for security: https://github.com/jlandure/alpine-chrome?tab=readme-ov-file#3-ways-to-securely-use-chrome-headless-with-this-image

To add Chrome to your Docker image:

```dockerfile
RUN apt-get update && apt-get install gnupg wget -y && \
    wget --quiet --output-document=- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google-archive.gpg && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
    apt-get update && \
    apt-get install google-chrome-stable -y && \
    rm -rf /var/lib/apt/lists/*
```

### Browser Management

FerrumPdf uses a single browser instance per Ruby process that is automatically created when needed using your configuration settings:

```ruby
# Browser is auto-created on first use
FerrumPdf.render_pdf(url: "https://example.org")
```

You can also set a custom browser instance:

```ruby
# Set a custom browser with specific options
custom_browser = Ferrum::Browser.new(window_size: [800, 600], headless: false)
FerrumPdf.browser = custom_browser

# All subsequent calls will use this browser
FerrumPdf.render_pdf(url: "https://example.org")
```

To safely shut down the browser process:

```ruby
# This will quit the current browser and set it to nil
FerrumPdf.browser = nil

# Next call will auto-create a new browser
FerrumPdf.render_pdf(url: "https://example.org")
```

> [!TIP]
> **Thread Safety**: FerrumPdf is thread-safe within a single Ruby process. Multiple threads can safely use FerrumPdf concurrently, and they will share the same Chrome browser instance. However, each Ruby worker process will have its own separate Chrome instance.

If you need multiple browsers, you can pass the browser option when rendering:

```ruby
other_browser = Ferrum::Browser.new
FerrumPdf.render_pdf(url: "https://example.org", browser: other_browser)
```

## Debugging

One option for debugging is to use Chrome in regular, non-headless mode:

```ruby
FerrumPdf.configure do |config|
  config.headless = false
end
```

FerrumPdf also allows you to pass a block for debugging. This block is executed after loading the page but before rendering the PDF or screenshot.

```ruby
FerrumPdf.render_pdf(url: "https://gooogle.com") do |browser, page|
  # Open Chrome DevTools to remotely inspect the browser
  browser.debug

  # Or pause and poke around
  binding.irb
end
```

The block will receive the `Ferrum::Browser` and `Ferrum::Page` objects which you can use for debugging.

## Contributing

If you have an issue you'd like to submit, please do so using the issue tracker in GitHub. In order for us to help you in the best way possible, please be as detailed as you can.

To run the test suite, run:

```bash
bin/test
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
