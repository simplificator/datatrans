Datatrans
=========

Ruby adapter for the Datatrans payment gateway (http://www.datatrans.ch).

Configuration
-------------

Buidl your Datatrans Configuration like so:

    datatrans = Datatrans::Config.new(
      :merchant_id => '1234567',
      :sign_key => 'ab739fd5b7c2a1...',
      :environment => :production,
      :proxy => {
        :http_proxyaddr => "proxy.com",
        :http_proxyport => 80,
        :http_proxyuser => "hans",
        :http_proxpass => "xxx",
      }
    )

If you don't want to use signed requests (disabled in datatrans web console), you can set `config.sign_key` to `false`.

Possible values for the environment: `:production`, `:development`

Web Authorization
=================

If you want to process a credit card the first time a web authorization is
necessary. Add the following code to a controller action that shows the form.
You need to pass at least `amount`, `currency` and `refno` (order number).
    @datatrans = Datatrans.new(...)
    @datatrans.web_transaction(params)
    @transaction = Datatrans::Web::Transaction.new(datatrans, {
      :amount => 1000, # in cents!
      :currency => 'CHF',
      :refno => 'ABCDEF',
      :uppCustomerEmail => 'customer@email.com'
      # feel free to add more upp infos here ...
    })

In your View your show the credit card form with a convenient helper:

    = form_tag Datatrans.web_authorize_url do

      = text_field_tag :paymentmethod, 'ECA'
      = text_field_tag :cardno
      = text_field_tag :expm
      = text_field_tag :expy
      = text_field_tag :cvv

      = hidden_field_tag :successUrl, <your_application_return_url>
      = hidden_field_tag :cancelUrl, <your_application_return_url>
      = hidden_field_tag :errorUrl, <your_application_return_url>

      = datatrans_notification_request_hidden_fields(datatrans, @transaction)

      = submit_tag "send"

In this example we use just ECA (Mastercard) as paymentmethod. Feel free to
provide an appropriate select field to offer more payment methods. Don't forget
to add `successUrl`, `cancelUrl` and `errorUrl`. We recommend to set them all
to the same value.

After you submit the request to Datatrans they redirect back to your application.
Now you can process the transaction like this:

    begin
      transaction = Datatrans::Web::Transaction.new(datatrans, params)

      if transaction.authorize
        # transaction was successful, access the following attributes
        # transaction.transaction_id
        # transaction.creditcard_alias
        # transaction.masked_cc
        # transaction.authorization_code
        # ...

      else
        # transaction was not successful, accces the error details
        # transaction.error_code, transaction.error_message, transaction.error_detail

      end
    rescue Datatrans::InvalidSignatureError => exception
      # the signature was wrong, the request may have been compromised...
    end

XML Transactions
================

If you have already a credit card alias or an authorized transaction you can
use the convenient XML methods to process payments.

Authorize
---------

    transaction = Datatrans::XML::Transaction.new(datatrans,
      :refno => 'ABCDEF',
      :amount => 1000, # in cents!
      :currency => 'CHF',
      :aliasCC => '8383843729284848348',
      :expm => 12,
      :expy => 15
    )

    if transaction.authorize
      # ok, the transaction is authorized...
      # access same values as in the web authorization (e.g. transaction.transaction_id)
    else
      # transaction.error_code, transaction.error_message, transaction.error_detail
    end


Capture
-------

To capture an authorized transaction you use the following code:

    transaction = Datatrans::XML::Transaction.new(datatrans,
      :refno => 'ABCDEF',
      :amount => 1000, # in cents!
      :currency => 'CHF',
      :transaction_id => 19834324987349723948729834
    )

    if transaction.capture
      # ok, the money is yours...
    else
      # transaction.error_code, transaction.error_message, transaction.error_detail
    end


Void
----

To make an authorized transaction invalid use void.

    transaction = Datatrans::XML::Transaction.new(datatrans,
      :refno => 'ABCDEF',
      :amount => 1000, # in cents!
      :currency => 'CHF',
      :transaction_id => 19834324987349723948729834
    )

    if transaction.void
      # ok, the transaction is not longer valid...
    else
      # transaction.error_code, transaction.error_message, transaction.error_detail
    end


CHANGELOG
=========

3.0.0
-------
* Refactored Code to allow multiple configurations
* Proxy config now uses HTTParty naming convention.

2.2.2
-------
* added ability to skip signing by setting config.sign_key = false


Todo
====

* allow signing of xml transactions
* allow signing with different keys
* add credit method to reverse already captured transactions
* add purchase method to authorize and capture in one step
* add url helpers for success, cancel and error urls
* extend configuration possibilities
* dry code more


Contribute
==========

* Fork the project.
* Make your feature addition or bug fix.
* Add specs for it. This is important so we don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself we can ignore when we pull)
* Send us a pull request. Bonus points for topic branches.


Credits
=======

Datatrans is maintained by Simplificator GmbH (http://simplificator.com).

The initial development was sponsered by Evita AG and Limmex AG.

License
=======

Datatrans is released under the MIT license.
