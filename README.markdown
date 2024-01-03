Datatrans
=========

Ruby adapter for the Datatrans payment gateway (http://www.datatrans.ch).

Configuration
-------------

Build your Datatrans Configuration like so:

```ruby
    datatrans = Datatrans::Config.new(
      :merchant_id => '1234567',
      :sign_key => 'ab739fd5b7c2a1...',
      :password => 'server to server request password',
      :environment => :production,
      :proxy => {
        :http_proxyaddr => "proxy.com",
        :http_proxyport => 80,
        :http_proxyuser => "hans",
        :http_proxpass => "xxx",
      }
    )
```

If you don't want to use signed requests (disabled in datatrans web console), you can set `config.sign_key` to `false`.
The configuration is then used as parameter to all the constructors and helpers, see examples below.

Possible values for the environment: `:production`, `:development`

Web Authorization
=================

If you want to process a credit card the first time a web authorization is
necessary. Add the following code to a controller action that shows the form.
You need to pass at least `amount`, `currency` and `refno` (order number).
```ruby
    @transaction = datatrans.web_transaction(
      :amount => 1000, # in cents!
      :currency => 'CHF',
      :refno => 'ABCDEF',
      :uppCustomerEmail => 'customer@email.com',
      # feel free to add more upp infos here ...
    )
```

In your View your show the credit card form with a convenient helper:

```ruby
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
```

In this example we use just ECA (Mastercard) as paymentmethod. Feel free to
provide an appropriate select field to offer more payment methods. Don't forget
to add `successUrl`, `cancelUrl` and `errorUrl`. We recommend to set them all
to the same value.

After you submit the request to Datatrans they redirect back to your application.
Now you can process the transaction like this:
```ruby
    begin
      transaction = datatrans.web_transaction(params)

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
```

JSON Transactions
=================

More information about Datatrans JSON API can be found [here](https://api-reference.datatrans.ch/). Our gem uses endpoints from `/v1/transactions` section. 

We implemented support for [Redirect mode](https://docs.datatrans.ch/docs/redirect-lightbox) (since Lightbox mode may not work correctly on mobile, whereas Redirect works well on all devises).

Authorize
---------

Authorize JSON transaction:

```ruby
transaction = datatrans.json_transaction(
  refno: 'ABCDEF',
  amount: 1000, # in cents!
  currency: "CHF",
  payment_methods: ["ECA", "VIS"],
  success_url: <your_application_return_url>,
  cancel_url: <your_application_return_url>,
  error_url: <your_application_return_url>
)

# call to init endpoint to initialize a transaction
# returns true or false depending if response was successful or not
init = transaction.authorize

# successful authorization call returns in response a transaction id
if init
  transaction_id = transaction.response.params["transactionId"]
end
```

Start a transaction
-------------------

Once you have a transaction id, you can start a transaction. Users of your application will be redirected to the datatrans payment pages: `https://pay.sandbox.datatrans.com/v1/start/{{transactionId}}`.

```ruby
 path = datatrans.json_transaction(transaction_id: transaction_id).transaction_path

 redirect_to path
 # or if you redirect after AJAX request:
 render js: "window.location='#{path}'"
```

You do not have to [settle a transaction](https://api-reference.datatrans.ch/#tag/v1transactions/operation/settle) by yourself: we set `"autoSettle": true` by default when authorizing a transaction, which means the transaction will be settled automatically. This can be overridden by setting `auto_settle: false` when authorizing a transaction.

Transaction status
------------------

You can check the trasaction [status](https://api-reference.datatrans.ch/#tag/v1transactions/operation/status), see its history and retrieve the card information.

```ruby
  transaction = datatrans.json_transaction(transaction_id: transaction_id)

  # status method returns true or false depending if response was successfull
  if transaction.status
    data = transaction.response.params
    # this will return following hash (may vary dependong on your payment method):
    {
      "transactionId"=>"230223022302230223",
      "merchantId"=>"1100000000",
      "type"=>"payment",
      "status"=>"settled",
      "currency"=>"CHF",
      "refno"=>"123456abc",
      "paymentMethod"=>"VIS",
      "detail"=>
        {"authorize"=>{"amount"=>1000, "acquirerAuthorizationCode"=>"100000"}, "settle"=>{"amount"=>1000}},
      "language"=>"en",
      "card"=>
        {"masked"=>"400000xxxxxx0018",
        "expiryMonth"=>"06",
        "expiryYear"=>"25",
        "info"=>
          {"brand"=>"VISA",
          "type"=>"debit",
          "usage"=>"consumer",
          "country"=>"SE",
          "issuer"=>"SVENSKA HANDELSBANKEN AB"},
        "3D"=>{"authenticationResponse"=>"Y"}},
      "history"=>
        [{"action"=>"init",
          "amount"=>1000,
          "source"=>"api",
          "date"=>"2023-06-06T08:37:23Z",
          "success"=>true,
          "ip"=>"8.8.8.8"},
        {"action"=>"authorize",
          "autoSettle"=>true,
          "amount"=>1000,
          "source"=>"redirect",
          "date"=>"2023-06-06T08:37:42Z",
          "success"=>true,
          "ip"=>"8.8.8.8"}]
    }
  else
    transaction.response.error_code
    transaction.response.error_message
  end
```


XML Transactions
================

XML API is [deprecated](https://mailchi.mp/datatrans/basic-authdynamic-sign_reminder) by Datatrans. After June 3rd, 2024 all merchants will have to use JSON API.

If you have already a credit card alias or an authorized transaction you can
use the convenient XML methods to process payments.

Authorize
---------

```ruby
    transaction = datatrans.xml_transaction(
      :refno => 'ABCDEF',
      :amount => 1000, # in cents!
      :currency => 'CHF',
      :aliasCC => '8383843729284848348',
      :expm => 12,
      :expy => 15,
    )

    if transaction.authorize
      # ok, the transaction is authorized...
      # access same values as in the web authorization (e.g. transaction.transaction_id)
    else
      # transaction.error_code, transaction.error_message, transaction.error_detail
    end
```


Capture
-------

To capture an authorized transaction you use the following code:

```ruby
    transaction = datatrans.xml_transaction(
      :refno => 'ABCDEF',
      :amount => 1000, # in cents!
      :currency => 'CHF',
      :transaction_id => 19834324987349723948729834,
    )

    if transaction.capture
      # ok, the money is yours...
    else
      # transaction.error_code, transaction.error_message, transaction.error_detail
    end
```

Void
----

To make an authorized transaction invalid use void.

```ruby
    transaction = datatrans.xml_transaction(
      :refno => 'ABCDEF',
      :amount => 1000, # in cents!
      :currency => 'CHF',
      :transaction_id => 19834324987349723948729834,
    )

    if transaction.void
      # ok, the transaction is not longer valid...
    else
      # transaction.error_code, transaction.error_message, transaction.error_detail
    end
```

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
