### Unreleased

* Replace controller methods with a Rails renderer

  This provides a much cleaner and better named Rails integration. You can pass options directly into the `render` method which will render the PDF or screenshot and pass it along to `send_data` for you.

  Before:

  ```ruby
  class PdfsController < ApplicationController
    def show
      respond_to do |format|
        format.pdf {
          pdf = render_pdf()
          send_data pdf, disposition: :inline, filename: "example.pdf"
        }
        format.png {
          screenshot = render_screenshot()
          send_data screenshot, disposition: :inline, filename: "example.png"
        }
      end
    end
  end
  ```

  After:

  ```ruby
  class PdfsController < ApplicationController
    def show
      respond_to do |format|
        format.pdf { render ferrum_pdf: {}, disposition: :inline, filename: "example.pdf" }
        format.png { render ferrum_screenshot: {}, disposition: :inline, filename: "example.png" }
      end
    end
  end
  ```



* [Breaking] Remove assets helper config option. This will always be included by default.

### 1.0.0

* No changes

### 0.5.0

* Thread safe browser management #63
* [Breaking] Remove `add_browser` feature to simplify the gem.

  You can pass `browser` to render methods to use your own `Ferrum::Browser` instance

  ```ruby
  FerrumPdf.render_pdf(url: "https://example.org", browser: Ferrum::Browser.new)
  ```

### 0.4.2

* Quit browser if a new one is added with the same name

### 0.4.1

* Safely handle html preprocessing when `base_url` is `nil`

### 0.4.0

* Add `FerrumPdf.configure` block for setting default browser options
* Restart the browser once if `Ferrum::DeadBrowserError` is raised
* Add `FerrumPdf.add_browser` to allow registering multiple browsers and referencing them by name

```ruby
FerrumPdf.add_browser :large, window_size: [1920, 1080]
```

* Add `browser: :name` option for overriding the default browser

```ruby
FerrumPdf.render_pdf(url: "https://example.org", browser: :large)
FerrumPdf.render_pdf(url: "https://example.org", browser: Ferrum::Browser.new)
```

* Simplify HTML preprocessing
  * Extract protocol from `base_url` instead of using a second arg
  * Remove `protocol` option
  * Rename `host` to `base_url`

* Add assets helpers to Rails views for dealing with Chrome quirks.
  https://nathanfriend.com/2019/04/15/pdf-gotchas-with-headless-chrome.html

```ruby
ferrum_pdf_inline_stylesheet("application.css")
ferrum_pdf_inline_javascript("application.js")
ferrum_pdf_base64_asset("logo.svg")
```

### 0.3.0

* Add `FerrumPdf.include_controller_module = false` option to skip adding `render_pdf` Rails helper
* Add `render_screenshot`

### 0.2.0

* Add support for `pdf_options`
* Add example for displaying header and footer
* Drop need for tempfile

### 0.1.1

* Relax Rails version requirements

### 0.1.0

* Initial release
