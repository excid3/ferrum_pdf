# https://github.com/rubycdp/ferrum/issues/82#issuecomment-2013496043
module Ferrum
  class Frame
    module DOM
      #
      # Finds a node using XPath or a CSS path selector, with waiting.
      #
      # @param [String] selector
      #   The XPath or CSS path selector.
      #
      # @param [Integer] init
      #   How long we should wait before starting to look.
      #
      # @param [Integer] wait
      #   How long we should wait for node to appear.
      #
      # @param [Integer] step
      #   How long to wait between checking.
      #
      # @return [Node, nil]
      #   The matching node.
      #
      # @example
      #   browser.wait_for("a[aria-label='CA']", init:1, wait:5, step:0.2) # => Node
      #
      def wait_for_selector(selector, init: nil, wait: 1, step: 0.1)
        sleep(init) if init
        meth = selector.start_with?("/") ? :at_xpath : :at_css
        until node = send(meth, selector) rescue nil
          (wait -= step) > 0 ? sleep(step) : break
        end
        node
      end
    end
  end
end
