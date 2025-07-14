### Unreleased

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
