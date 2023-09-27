# Changelog
All notable changes to this project made by Monade Team are documented in this file. For info refer to team@monade.io

## [2.0.0-BETA] - 2023-09-27
### Added
- `transformer` option to param, that allows to transform the value received from a parameter before assigning it to the sanitized hash.
- `default` now works also with nested structures.

### Changed
- [BREAKING] All methods can now be called without ! (param, params, default, etc...)
- [BREAKING] `array` and `group` are not identical anymore. `array` will accepts an array of values, while `group` will accept a single hash.
- [BREAKING] internal, removed to_defaults, replacing it with apply_defaults!

### Fixed
- Missing params in nested structures are now reported correctly


## [1.0.0] - 2022-05-28
### Added
- First release
