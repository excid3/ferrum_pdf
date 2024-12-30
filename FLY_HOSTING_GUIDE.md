# Fly.io hosting guide

To ensure FerrumPdf works as expected in the Fly.io hosting environment, we need
to make sure Chrome is installed via Docker and running with the --no-sandbox flag.

## Dockerfile dependencies

First, add these dependencies to the Dockerfile used when deploying to Fly.io.

```
ENV DOCKER_BUILD=1
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    chromium chromium-sandbox fonts-liberation libappindicator3-1 xdg-utils && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt
```

I've also set `DOCKER_BUILD`, so the initializer is skipped when building the
image (FerrumPdf will timeout since Chrome is not yet installed).

## Initialize with options

Fly.io does not allow Chrome to run in sandbox mode, so we need to disable it.

```ruby
# config/initializers/ferrum.rb

return if ENV['DOCKER_BUILD']

options = {
  process_timeout: 30,
  browser_options: {
    'no-sandbox' => nil
  }
}

options = options.merge(browser_path: '/usr/bin/chromium') if Rails.env.production?

FerrumPdf.browser(options)
```

Additionally, increasing the process timeout avoids code reloading issues in
development as detailed here: [Possibility to set Ferrum timeout to overcome code reloading issues in Development](https://github.com/excid3/ferrum_pdf/issues/5).

`fly deploy` these changes, confirm the build step succeeds and FerrumPdf generates pdfs as expected.
