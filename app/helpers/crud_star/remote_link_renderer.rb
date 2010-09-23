# Extends will_paginate to provide AJAX links which will also degrade for
# non-Javascript browsers.
#
# Based on the example from http://weblog.redlinesoftware.com/2008/1/30/willpaginate-and-remote-links
#
require 'will_paginate'

module CrudStar
  class RemoteLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
    
    private

      def link(text, target, attributes = {})
        attributes['data-remote'] = true
        super(text, target, attributes)
      end
  end
end