# Changelog

## [3.0.0] — 2026-04-02

This is a clean-break fork of [biola/turnout](https://github.com/biola/turnout) v2.5.0,
renamed and modernized for Ruby 3.1+ and Rack 3.

### Breaking Changes

- **Gem renamed** from `turnout` to `turndown`; module renamed `Turnout` → `Turndown`
- **Class renamed** `Rack::Turnout` → `Rack::Turndown`
- **Ruby 3.1+ required** (`required_ruby_version = '>= 3.1'`)
- **Rack 3 required headers**: all response headers are now lowercase (`content-type`, `retry-after`)
- **`rack-accept` dependency dropped** — content negotiation is now inline
- **`i18n` dependency dropped** — the gem no longer localizes maintenance pages
- **`OrderedOptions` removed** — was only used for i18n configuration
- **`MaintenanceFile` is no longer passed directly to `Request#allowed?`** — the middleware now passes a `MaintenanceState` value object instead (internal change, no public API impact for typical use)

### New Features

#### ENV-variable activation (primary for containerized deployments)

Set environment variables to activate maintenance mode without touching the filesystem:

```sh
TURNDOWN_ENABLED=1
TURNDOWN_REASON="Deploying v2.0 — back in 5 minutes"
TURNDOWN_ALLOWED_IPS="1.2.3.4,10.0.0.0/8"
TURNDOWN_ALLOWED_PATHS="^/healthz,^/status"
TURNDOWN_RESPONSE_CODE=503
TURNDOWN_RETRY_AFTER=300
```

ENV is read on every request — no restart required.

#### Provider architecture

Maintenance state is now resolved by an ordered list of provider classes:

```ruby
Turndown.config.providers  # => [Turndown::Provider::Env, Turndown::Provider::File]
```

The first provider that returns an active state wins. To customize:

```ruby
# ENV-only (ignore file):
Turndown.configure { |c| c.providers = [Turndown::Provider::Env] }

# File-only (ignore ENV):
Turndown.configure { |c| c.providers = [Turndown::Provider::File] }

# Custom ENV prefix:
Turndown.configure { |c| c.env_prefix = 'APP_MAINTENANCE' }
# → reads APP_MAINTENANCE_ENABLED, APP_MAINTENANCE_REASON, etc.
```

#### `MaintenanceState` value object

`Turndown::MaintenanceState` is the unified output of both providers. It carries
`reason`, `allowed_paths`, `allowed_ips`, `response_code`, and `retry_after`.

### Dependency Changes

| Gem | Old | New |
|---|---|---|
| `rack` | `>= 1.3, < 3` | `>= 2.2, < 4` |
| `tilt` | `>= 1.4, < 3` | `~> 2.0` |
| `rack-accept` | `~> 0.4` | **dropped** |
| `i18n` | `>= 0.7, < 2` | **dropped** |
| `rack-test` (dev) | `~> 0.6` | `~> 2.0` |
| `simplecov` (dev) | `~> 0.10` | `~> 0.22` |
| `rspec-its` (dev) | `~> 1.0` | **dropped** |
| `simplecov-summary` (dev) | any | **dropped** |
| `rubocop` (dev) | — | `~> 1.60` |
| `rubocop-rspec` (dev) | — | `~> 2.0` |

### Migrating from Turnout

1. Replace `gem 'turnout'` with `gem 'turndown'` in your Gemfile
2. Replace `require 'turnout'` / `require 'rack/turnout'` with `require 'turndown'` / `require 'rack/turndown'`
3. Replace `Rack::Turnout` with `Rack::Turndown` in middleware configuration
4. Replace `Turnout.configure` with `Turndown.configure`
5. Remove any i18n configuration blocks — they are no longer supported
6. Update response header assertions in tests from `'Content-Type'` to `'content-type'`
