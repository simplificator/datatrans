Datatrans
=========

Ruby adapter for the Datatrans payment gateway (http://www.datatrans.ch).

Usage
=====

Configuration
-------------

    Datatrans.configure do |config|
      config.merchant_id = '1234567'
      config.sign_key = '...'
      config.environment = :production
    end

Possible values for the environment: `:production`, `:development`

Controller
----------

If you are restful the following code could be your "new" method.

    @datatrans_request = Datatrans::Notification::Request.new({
      :amount => 1000,
      :currency => 'CHF',
      :refno => "your order no or sth else",
      :uppCustomerEmail => current_account.email,
      # feel free to add more upp infos here ...
      :reqtype => 'NOA', # just authorize, we capture later, otherwise use CAA
      :hiddenMode => 'yes' # datatrans should not show any dialogs
    })

After you submit the request to Datatrans they redirect back to your application.
Just pass your application's success\_url, cancel\_url and error\_url (see View section).
This code could be your "create" method.

    begin
      datatrans_response = Datatrans::Notification::Response.new(params)
      
      if datatrans_response.success? && datatrans_response.valid_signature?
        # transaction was successfully carried out...
        # datatrans_response.reference_number
        # datatrans_response.transaction_id
        # datatrans_response.creditcard_alias
        
      elsif datatrans_response.cancel?
        # transaction was cancelled...
      
      elsif datatrans_response.error?
        # an error occured...
      
      end
    rescue Datatrans::Notification::InvalidSignatureError => exception
      # invalid datatrans notification, signature does not match...
    end
  
View
----

In this example we use just ECA (Mastercard) as paymentmethod. Feel free to
provide an appropriate select field to offer more payment methods. This is the
form you will show in your "new" method.

    = form_tag Datatrans.web_authorize_url do
    
      = text_field_tag :paymentmethod, 'ECA'
      = text_field_tag :cardno
      = text_field_tag :expm
      = text_field_tag :expy
      = text_field_tag :cvv
    
      = hidden_field_tag :successUrl, <your_application_return_url>
      = hidden_field_tag :cancelUrl, <your_application_return_url>
      = hidden_field_tag :errorUrl, <your_application_return_url>
    
      = datatrans_notification_request_hidden_fields(@datatrans_request)
    
      = submit_tag "send"

Model
-----

To capture an authorized transaction you use the following code:

    begin
      Datatrans::Transaction.new(
        :refno => "your order no or sth else",
        :amount => 1000,
        :currency => 'CHF',
        :transaction_id => "your transaction id"
      ).capture
    rescue
      # do something about it...
    end
  
To authorize a new transaction (you need the alias CC of a previous transaction) use that code:
  
    begin
      transaction = Datatrans::Transaction.new(
        :refno => "your order no or sth else",
        :amount => 1000,
        :currency => 'CHF',,
        :aliasCC => "alias CC no",
        :expm => 12,
        :expy => 15
      ).authorize
      
      # now save the transaction.transaction_id
      # and e.g. the transaction.masked_cc
    rescue
      # do something about it...
    end
  
  
Credits
=======

Datatrans is maintained by Simplificator GmbH (http://simplificator.com).

The initial development was sponsered by Evita AG and Limmex AG.

License
=======

Datatrans is released under the MIT license.
