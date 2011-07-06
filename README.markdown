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

TODO

View
----

TODO

Credits
=======

Datatrans is maintained by Simplificator GmbH (http://simplificator.com).

The initial development was sponsered by Evita AG and Limmex AG.

License
=======

Datatrans is released under the MIT license.
