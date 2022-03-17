# Datatrans Changelog

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

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


