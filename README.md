# FerrumPdf

PDFs for Rails using [Ferrum](https://github.com/rubycdp/ferrum) & headless Chrome

## Installation

Run the following or add the gem to your Gemfile:

```ruby
bundle add "ferrum_pdf"
```

## Usage

### Rails controllers

Use the `render_pdf` helper in Rails controllers to render a PDF from the current action.

```ruby
def show
  respond_to do |format|
    format.html
    format.pdf { send_data render_pdf, disposition: :inline, filename: "example.pdf" }
  end
end
```

You can also customize which template is rendered:

```ruby
render_pdf(name = action_name, formats: [ :html ])
```

This will render the template to string, then pass it along to FerrumPdf.

### Directly with HTML

FerrumPdf can generate a PDF from HTML directly:

```ruby
FerrumPdf.render_pdf(html: content)
```

You can also pass host and protocol to convert any relative paths to full URLs. This is helpful for converting relative asset paths to full URLs.

```ruby
FerrumPdf.render_pdf(
  html: content,
  host: request.host_with_port,
  protocol: request.protocol
)
```

## Contributing

If you have an issue you'd like to submit, please do so using the issue tracker in GitHub. In order for us to help you in the best way possible, please be as detailed as you can.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
