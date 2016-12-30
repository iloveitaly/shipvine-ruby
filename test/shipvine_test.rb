require 'test_helper'

class ShipvineTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Shipvine::VERSION
  end

  def test_inbound_shipment
    Shipvine::InboundShipment.get('merchant-id')
  end
end
