require "shipvine/version"

require 'httparty'
require 'gyoku'
require 'nori'

require 'shipvine/error'
require 'shipvine/client'
require 'shipvine/base'
require 'shipvine/fulfillment_request'
require 'shipvine/inbound_shipment'
require 'shipvine/outbound_shipment'
require 'shipvine/bill_of_lading'
require 'shipvine/deep_compact'

module Shipvine
  class << self
    attr_accessor :api_key, :merchant_code, :validate_xml, :testmode
  end
end
