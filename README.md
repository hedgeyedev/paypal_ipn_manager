# PayPal IPN Manager

An Elixir server that buffers PayPal IPN notifications to your business app

## Status

*Under construction.*

## "Business Rules"

1. Can acknowledge IPN messages in any order when PayPal has sent us a bunch.
1. Must maintain `profile_id` sequence order of IPN messages into our application.  I.e., a profile cannot
   receive a recurring payment IPN before the IPN that creates the payment.

## Tasks

1. Read PayPal Sandbox's IPN HTTP Request
1. Parse the request for the following:
   * The PayPal ID
   * The identification of the transmitting PayPal server or sandbox
1. Start an asynchronous process to perform the SSL HTTP acknowledgement back to the transmitting PayPal box.
1. In the started process:
   * when it completes successfully, forward the request to the Hedgeye application's background_fu.
   * when it fails from timeout, restart it
   * when it fails for any other reason, send an email.
