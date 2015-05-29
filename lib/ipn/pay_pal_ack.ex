defmodule Ipn.PayPalAck do
  @moduledoc """
  Handle verifying that an IPN has come from PayPal by reflecting it back to PayPal
  which will respond whether it was the source of the IPN or not.
  """
  use HTTPoison.Base

  # Define a test URL until we actually develop a facility to manage the PayPal callback URLs:
  @local_server = "http://127.0.0.1:5454"
  @endpoint "#{@local_server}/paypal_ack"

  def format_ack(ipn) do

  end

  # Perform an acknowledgement for an IPN with the PayPal source.
  # Return:
  # * true if PayPal returns "VERIFIED"
  # * false if PayPal returns "INVALID"
  # Raise if anything else happens
  def ack(ipn) do
    case
  end

end
