# Datatrans Changelog

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## 5.2.0 - 2024-01-31

### Added

* Support for Ruby 3.3 and Rails 7.1 (@andyundso [#47](https://github.com/simplificator/datatrans/pull/47))
* Support for Merchant Initiated Payments (@visini [#48](https://github.com/simplificator/datatrans/pull/48), [#52](https://github.com/simplificator/datatrans/pull/52), [#53](https://github.com/simplificator/datatrans/pull/53), [#56](https://github.com/simplificator/datatrans/pull/56))

### Changed

* Reformatted code with standardrb (@andyundso [#57](https://github.com/simplificator/datatrans/pull/57))
* Marked XML APIs and Web APIs as deprecated (@andyundso [#60](https://github.com/simplificator/datatrans/pull/60))
* Renamed `Datatrans::JSON::Transaction::Authorize` to `Datatrans::JSON::Transaction::Init`. `::Authorize` will still work until the next major release (@andyundso [#60](https://github.com/simplificator/datatrans/pull/60))

## 5.1.0 - 2023-07-06

### Added

* Test against Ruby 3.2 (@andyundso [#43](https://github.com/simplificator/datatrans/pull/43))
* Add support for Datatrans JSON API (@TatianaPan [#45](https://github.com/simplificator/datatrans/pull/45)). Check Readme for details on how to use it.

XML API is [deprecated](https://mailchi.mp/datatrans/basic-authdynamic-sign_reminder) by Datatrans and will not be supported by them after June 3rd, 2024. Consider to moving to a [new JSON API](https://api-reference.datatrans.ch/).

## 5.0.0 - 2022-09-21

### Changed

* [BREAKING CHANGE] Authenticate requests with HTTP Basic Auth (@crackofdusk [#41](https://github.com/simplificator/datatrans/pull/41))

  Datatrans requires [HTTP Basic Auth for XML API calls](https://api-reference.datatrans.ch/xml/#authentication-tls) since 2022-09-14 ([announcement](https://mailchi.mp/datatrans/basic-authsign2_1-email_en))

## 4.0.1 - 2022-03-18
### Fixed
* Check for successful transaction depends on `status` and not on `response_message` that can be diferent for different payment methods (@schmijos [#8](https://github.com/simplificator/datatrans/pull/8) and @TatianaPan [#39](https://github.com/simplificator/datatrans/pull/39))
## 4.0.0 - 2022-02-25
### Changed
* [BREAKING CHANGE] Bump minimum required Ruby version to 2.6 and Rails to 5.2 (@andyundso [#34](https://github.com/simplificator/datatrans/pull/34))
* Change Datatrans hostnames (@rgisiger [#32](https://github.com/simplificator/datatrans/pull/32))

## 3.0.2 - 2014-01-04
### Added
* Specified MIT License.

## 3.0.0 - 2013-09-25
### Changed
* Refactored code to allow multiple configurations
* Proxy config now uses HTTParty naming convention.

## 2.2.2 - 2011-10-11
### Added

* ability to skip signing by setting `config.sign_key = false`

## 1.0.0 - 2011-07-07

Initial release


