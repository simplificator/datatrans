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

> [!IMPORTANT]
>
> Datatrans no longer supports the Payment Page API. The support in this gem will be removed in the next major release. Please use the [JSON API](#json-transactions) instead.

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

We implemented support for [Redirect mode](https://docs.datatrans.ch/docs/redirect-lightbox) (since Lightbox mode may not work correctly on mobile, whereas Redirect works well on all devices).

Saving Payment Information
--------------------------

According to the [docs](https://docs.datatrans.ch/docs/customer-initiated-payments#saving-payment-information), there are three possible flows:

- **Customer Initiated Payments**: _Your customer pays and nothing is registered._
  - This is the most basic setup and does _not_ save any payment information: First, call `transaction.init`, and then redirect the user to the `transaction_path` (see the sections `Initialize` and `Start a transaction` below).
- **Customer Initiated Payment** and creating an `alias` for subsequent **Merchant Initiated Payments**: _Your customer pays and the card or payment method information is registered. You receive an alias which you save for later merchant initiated payments or one-click checkouts._
  - In order to save payment information after your customer has finalized their payment, without them having to re-enter their payment information and go through the 3D-Secure flow, pass `option: {"createAlias": true}`. More information can be found [here](https://docs.datatrans.ch/docs/redirect-lightbox#saving-payment-information).
- **Merchant Initiated Payments**: _Your customer registers their card or payment method information without any payment. Their account is not charged. This is what we call a dedicated registration._
  - This setup allows you to save a customers payment information without any charge in the beginning. This is useful in the context of setting up a subscription model (e.g., usage-based billing at the end of a billing period). See the section `Merchant Initiated Payments` below.

Initialize
---------

Initialize a JSON transaction:

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

# call to initialize endpoint to initialize a transaction
# returns true or false depending if response was successful or not
init = transaction.init

# successful authorization call returns in response a transaction id
if init
  transaction_id = transaction.response.params["transactionId"]
end
```

You can set any additional properties like custom webhook URLs in the json payload by passing `additional_options: <your options>`.
See the API documentation for all available options [here](https://api-reference.datatrans.ch/). 


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

Merchant Initiated Payments
---------

It's possible to authorize transactions without user interaction, via [merchant initiated payments](https://docs.datatrans.ch/docs/merchant-initiated-payments).

To perform a so-called "dedicated registration" (so we can later charge the card via its `alias`), you should follow the same steps as described above, but not provide an amount:

```ruby
transaction = datatrans.json_transaction(
  refno: 'ABCDEF',
  amount: 0, # omit amount for dedicated registrations
  currency: "CHF",
  payment_methods: ["ECA", "VIS"],
  success_url: <your_application_return_url>,
  cancel_url: <your_application_return_url>,
  error_url: <your_application_return_url>
)

init = transaction.init

# successful authorization call returns in response a transaction id
if init
  transaction_id = transaction.response.params["transactionId"]
end
```

Then, at a later point in time, and without needing any user interaction, you can create a payment via `merchant_authorize`:

```ruby
dedicated_registration = datatrans.json_transaction(transaction_id: transaction_id)
dedicated_registration.status # this will contain the card information

card_alias = dedicated_registration.response.params["card"]["alias"]
card_expiry_month = dedicated_registration.response.params["card"]["expiryMonth"]
card_expiry_year = dedicated_registration.response.params["card"]["expiryYear"]

transaction = datatrans.json_transaction(
  refno: "ABCDEF",
  amount: 1000,
  currency: "CHF",
  card: {alias: card_alias, expiryMonth: card_expiry_month, expiryYear: card_expiry_year}
)

transaction.merchant_authorize # this will charge the card without user interaction
```

XML Transactions
================

> [!IMPORTANT]
>
> Datatrans will stop supporting the XML API on June 3rd, 2024. The support in this gem will be removed in the next major release. Please use the [JSON API](#json-transactions) instead.

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
