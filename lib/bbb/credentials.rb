# frozen_string_literal: true

#  BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
#  Copyright (c) 2020 BigBlueButton Inc. and by respective authors (see below).
#
#  This program is free software; you can redistribute it and/or modify it under the
#  terms of the GNU Lesser General Public License as published by the Free Software
#  Foundation; either version 3.0 of the License, or (at your option) any later
#  version.
#
#  BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
#  PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License along
#  with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

require 'net/http'
require 'xmlsimple'
require 'json'

module Bbb
  class Credentials

    attr_writer :cache, :cache_enabled # Rails.cache store is assumed.  # Enabled by default.
    attr_reader :secret

    def initialize(endpoint, secret)
      # Set default credentials.
      @endpoint = endpoint
      @secret = secret
      @cache_enabled = true
    end

    def endpoint
      fix_bbb_endpoint_format(@endpoint)
    end

    private

    # Fixes BigBlueButton endpoint ending.
    def fix_bbb_endpoint_format(endpoint)
      # Fix endpoint format only if required.
      endpoint += '/' unless endpoint.ends_with?('/')
      endpoint += 'api/' if endpoint.ends_with?('bigbluebutton/')
      endpoint += 'bigbluebutton/api/' unless endpoint.ends_with?('bigbluebutton/api/')
      endpoint
    end
  end
end
