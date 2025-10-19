<div align="center">

# PHP Matrix Action

[![GitHub Release](https://img.shields.io/github/v/release/typisttech/php-matrix-action)](https://github.com/typisttech/php-matrix-action/releases/latest)
[![GitHub Marketplace](https://img.shields.io/badge/marketplace-php--matrix-blue?logo=github)](https://github.com/marketplace/actions/php-matrix)
[![Test](https://github.com/typisttech/php-matrix-action/actions/workflows/test.yml/badge.svg)](https://github.com/typisttech/php-matrix-action/actions/workflows/test.yml)
[![License](https://img.shields.io/github/license/typisttech/php-matrix-action.svg)](https://github.com/typisttech/php-matrix-action/blob/master/LICENSE)
[![Follow @TangRufus on X](https://img.shields.io/badge/Follow-TangRufus-15202B?logo=x&logoColor=white)](https://x.com/tangrufus)
[![Follow @TangRufus.com on Bluesky](https://img.shields.io/badge/Bluesky-TangRufus.com-blue?logo=bluesky)](https://bsky.app/profile/tangrufus.com)
[![Sponsor @TangRufus via GitHub](https://img.shields.io/badge/Sponsor-TangRufus-EA4AAA?logo=githubsponsors)](https://github.com/sponsors/tangrufus)
[![Hire Typist Tech](https://img.shields.io/badge/Hire-Typist%20Tech-778899)](https://typist.tech/contact/)

<p>
  <strong>Generate PHP version matrix according to <code>composer.json</code></strong>
  <br>
  <br>
  Built with ♥ by <a href="https://typist.tech/">Typist Tech</a>
</p>

</div>

---

> [!TIP]
> **Hire Tang Rufus!**
>
> I am looking for my next role, freelance or full-time.
> If you find this tool useful, I can build you more dev tools like this.
> Let's talk if you are hiring PHP / Ruby / Go developers.
>
> Contact me at https://typist.tech/contact/

---

## Usage

See [action.yml](action.yml) and the underlying script [`typisttech/php-matrix`](https://github.com/typisttech/php-matrix/#options).

```yaml
  - uses: typisttech/php-matrix-action@v2
    with:
      # Path to composer.json
      #
      # Default: composer.json
      composer-json: some/path/to/composer.json
      
      # Version format.
      #
      # Available modes:
      #   - `minor-only`: Report `MAJOR.MINOR` versions only
      #   - `full`: Report all satisfying versions in `MAJOR.MINOR.PATCH` format
      #
      # Default: minor-only
      mode: full

      # Source of releases information.
      #
      # Available sources:
      #   - `auto`: Use `offline` in `minor-only` mode. Otherwise, fetch from [php.net]
      #   - `php.net`: Fetch releases information from [php.net]
      #   - `offline`: Use [hardcoded releases] information
      #
      # [php.net]: https://www.php.net/releases/index.php
      # [hardcoded releases]: https://github.com/typisttech/php-matrix/blob/main/resources/all-versions.json
      #
      # Default: auto
      source: offline

      # PHP Matrix version.
      # 
      # The version of [php-matrix] to use. Leave blank for latest. For example: v1.0.2
      # 
      # [php-matrix]: https://github.com/typisttech/php-matrix
      #
      # Default: ''
      version: v1.0.2

      # Verify Attestation
      #
      # Whether to verify PHP matrix tarball attestation.

      # Github Token
      #
      # GitHub token to use for authentication
      #
      # Default: ${{ github.token }}
      github-token: ${{ secrets.GITHUB_PAT_TOKEN }}
```

### Outputs

| Key | Description | Example |
| --- | --- | --- |
| `constraint`  | PHP constraint found in `composer.json` | `^7.3 \|\| ^8.0` |
| `versions` | String of an array of all supported PHP versions | In `minor-only` mode, `["7.3", "7.4", "8.0", "8.1", "8.2", "8.3", "8.4"]`<br><br>In `full` mode, `["7.4.998", "7.4.999", "8.4.998", "8.4.999"]` |
| `lowest` | Lowest supported PHP versions | In `minor-only` mode, `7.3`<br><br>In `full` mode, `7.3.0` |
| `highest` | Highest supported PHP versions | In `minor-only` mode, `8.4`<br><br>In `full` mode, `8.4.2` |

> [!TIP]
> **Hire Tang Rufus!**
>
> There is no need to understand any of these quirks.
> Let me handle them for you.
> I am seeking my next job, freelance or full-time.
>
> If you are hiring PHP / Ruby / Go developers,
> contact me at https://typist.tech/contact/

## Examples

<details open>
  <summary>Run tests against all supported PHP versions.</summary>

```yaml
name: Test

on:
  push:

jobs:
  php-matrix:
    runs-on: ubuntu-latest
    outputs:
      versions: ${{ steps.php-matrix.outputs.versions }}
    steps:
      - uses: actions/checkout@v5
        with:
          sparse-checkout: composer.json
          sparse-checkout-cone-mode: false

      - uses: typisttech/php-matrix-action@v2
        id: php-matrix

  test:
    runs-on: ubuntu-latest
    needs: php-matrix
    strategy:
      matrix:
        php-version: ${{ fromJSON(needs.php-matrix.outputs.versions) }}
    steps:
      - uses: actions/checkout@v5
      - uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ matrix.php-version }}
      - run: composer install
      - run: composer test
```
</details>

<details>
  <summary>Run tests on the highest supported PHP version only.</summary>

```yaml
name: Test

on:
  push:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5

      - uses: typisttech/php-matrix-action@v2
        id: php-matrix

      - uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ steps.php-matrix.outputs.highest }}

      - run: composer install
      - run: composer test
```
</details>

<details>
  <summary>Run `$ composer audit` against all supported PHP versions.</summary>

```yaml
name: Composer Audit

on:
  push:

jobs:
  php-matrix:
    runs-on: ubuntu-latest
    outputs:
      versions: ${{ steps.php-matrix.outputs.versions }}
      highest: ${{ steps.php-matrix.outputs.highest }}
      lowest: ${{ steps.php-matrix.outputs.lowest }}
    steps:
      - uses: actions/checkout@v5
        with:
          sparse-checkout: composer.json
          sparse-checkout-cone-mode: false

      - uses: typisttech/php-matrix-action@v2
        id: php-matrix

  composer-audit:
    needs: php-matrix
    runs-on: ubuntu-latest
    strategy:
      matrix:
        php-version: ${{ fromJSON(needs.php-matrix.outputs.versions) }}
        dependency-versions: [highest]
        include:
          - php-version: ${{ needs.php-matrix.outputs.lowest }}
            dependency-versions: lowest
          - php-version: ${{ needs.php-matrix.outputs.highest }}
            dependency-versions: locked
    env:
      COMPOSER_NO_AUDIT: 1
    steps:
      - uses: actions/checkout@v5
        with:
          sparse-checkout: |
            composer.json
            composer.lock
          sparse-checkout-cone-mode: false

      - uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ matrix.php-version }}
          coverage: none
      - uses: ramsey/composer-install@v3
        with:
          dependency-versions: ${{ matrix.dependency-versions }}

      - run: composer audit
```
</details>

## Credits

[`PHP Matrix Action`](https://github.com/typisttech/php-matrix-action) is a [Typist Tech](https://typist.tech) project and
maintained by [Tang Rufus](https://x.com/TangRufus), freelance developer [for hire](https://typist.tech/contact/).

Full list of contributors can be found [on GitHub](https://github.com/typisttech/php-matrix-action/graphs/contributors).

## Copyright and License

This project is a [free software](https://www.gnu.org/philosophy/free-sw.en.html) distributed under the terms of
the MIT license. For the full license, see [LICENSE](LICENSE).

## Contribute

Feedbacks / bug reports / pull requests are welcome.
