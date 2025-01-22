# Fly.io hosting guide

To ensure FerrumPdf works as expected in the Fly.io hosting environment, we need
to make sure Chrome is installed via Docker and running with the --no-sandbox flag.

## Dockerfile dependencies

First, add these dependencies to the Dockerfile used when deploying to Fly.io.

```
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    chromium chromium-sandbox fonts-liberation libappindicator3-1 xdg-utils && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt
```

## Initialize with options

Fly.io does not allow Chrome to run in sandbox mode, so we need to disable it.

Additionally, in my testing, setting browser options via FerrumPdf did not work
as expected once deployed. In production, we need to initialize Ferrum::Browser directly and
set it directly in FerrumPdf.

```ruby
# config/initializers/ferrum.rb

if Rails.env.production?
  require 'ferrum'

  FERRUM_BROWSER = Ferrum::Browser.new(
    browser_options: {
      "no-sandbox" => true,
      "headless" => "new"
    },
    process_timeout: 30,
    browser_path: '/usr/bin/chromium'
  )

  # Configure FerrumPdf to use our browser instance
  module FerrumPdf
    class << self
      def browser
        FERRUM_BROWSER
      end
    end
  end
end
```

Increasing the process timeout avoids code reloading issues in
development as detailed here: [Possibility to set Ferrum timeout to overcome code reloading issues in Development](https://github.com/excid3/ferrum_pdf/issues/5).

`fly deploy` these changes, confirm the build step succeeds and FerrumPdf generates pdfs as expected.
