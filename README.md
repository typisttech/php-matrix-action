<div align="center">

# PHP Matrix Action

[![GitHub Release](https://img.shields.io/github/v/release/typisttech/php-matrix-action)](https://github.com/typisttech/php-matrix-action/releases/latest)
[![GitHub Marketplace](https://img.shields.io/badge/marketplace-php--matrix-blue?logo=github&style=flat-square)](https://github.com/marketplace/actions/php-matrix)
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

## Usage

See [action.yml](action.yml) and the underlying script [`typisttech/php-matrix`](https://github.com/typisttech/php-matrix/#options).

```yaml
  - uses: typisttech/php-matrix-action@v1
    with:
      # Version format.
      #
      # Available modes:
      #   - `minor-only`: Report `MAJOR.MINOR` versions only
      #   - `full`: Report all satisfying versions in `MAJOR.MINOR.PATCH` format
      #
      # Default: minor-only
      mode: ''

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
      source: ''
```

### Outputs

This action yields a single output `matrix` which is a JSON-encoded string of:

| Key | Description | Example |
| --- | --- | --- |
| `constraint`  | PHP constraint found in `composer.json` | `^7.3 \|\| ^8.0` |
| `versions` | Array of all supported PHP versions | In `minor-only` mode, `["7.3", "7.4", "8.0", "8.1", "8.2", "8.3", "8.4"]`<br><br>In `full` mode, `["7.4.998", "7.4.999", "8.4.998", "8.4.999"]` |
| `lowest` | Lowest supported PHP versions | In `minor-only` mode, `7.3`<br><br>In `full` mode, `7.3.0` |
| `highest` | Highest supported PHP versions | In `minor-only` mode, `8.4`<br><br>In `full` mode, `8.4.2` |

> [!TIP]
>
> Use [`fromJSON()`](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/evaluate-expressions-in-workflows-and-actions#fromjson) and [`toJSON()`](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/evaluate-expressions-in-workflows-and-actions#tojson) to decode the output.
>
> ```yaml
> jobs:
>   php-matrix:
>     runs-on: ubuntu-latest
>     outputs:
>       matrix: ${{ steps.php-matrix.outputs.matrix }}
>       constraint: ${{ fromJSON(steps.php-matrix.outputs.matrix).constraint }}
>       # Use `fromJSON()` when accessing `versions`!
>       versions: ${{ toJSON(fromJSON(steps.php-matrix.outputs.matrix).versions) }}
>       lowest: ${{ fromJSON(steps.php-matrix.outputs.matrix).lowest }}
>       highest: ${{ fromJSON(steps.php-matrix.outputs.matrix).highest }}
>     steps:
>       - uses: actions/checkout@v4
>       - uses: typisttech/php-matrix-action@main
>         id: php-matrix
> ```

## Examples

<details>
  <summary>Run tests against all supported PHP minor versions.</summary>

```yaml
name: Test

on:
  push:

jobs:
  php-matrix:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.php-matrix.outputs.matrix }}
    steps:
      - uses: actions/checkout@v4
      - uses: typisttech/php-matrix-action@v1
        id: php-matrix

  test:
    runs-on: ubuntu-latest
    needs: php-matrix
    strategy:
      matrix:
        php: ${{ fromJSON(needs.php-matrix.outputs.matrix).versions }}
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ matrix.php }}
      - run: composer install
      - run: composer test
```

</details>

<details>
  <summary>Run `$ pint --test` with the lowest supported PHP minor version.</summary>

```yaml
name: Pint

on:
  push:

jobs:
  pint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: typisttech/php-matrix-action@v1
        id: php-matrix

      - uses: shivammathur/setup-php@v2
        with:
          php-version:  ${{ fromJSON(steps.php-matrix.outputs.matrix).lowest }}
          tools: pint

      - run: pint --test
```

</details>

<details>
  <summary>Run tests with coverage.</summary>

```yaml
name: Test

on:
  push:

jobs:
  php-matrix:
    runs-on: ubuntu-latest
    outputs:
      versions: ${{ toJSON(fromJSON(steps.php-matrix.outputs.matrix).versions) }}
      highest: ${{ fromJSON(steps.php-matrix.outputs.matrix).highest }}
    steps:
      - uses: actions/checkout@v4
        with:
          sparse-checkout: composer.json
          sparse-checkout-cone-mode: false

      - uses: typisttech/php-matrix-action@v1
        id: php-matrix

  test:
    runs-on: ubuntu-latest
    needs: php-matrix
    strategy:
      matrix:
        php: ${{ fromJSON(needs.php-matrix.outputs.versions }}
        dependency-versions: [lowest, highest]
        coverage: [none]
        exclude:
          - php: ${{ needs.php-matrix.outputs.highest }}
            dependency-versions: highest
            coverage: none
        include:
          - php: ${{ needs.php-matrix.outputs.highest }}
            dependency-versions: highest
            coverage: xdebug
    steps:
      - uses: actions/checkout@v4

      - uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ matrix.php }}
          coverage: ${{ matrix.coverage }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - uses: ramsey/composer-install@v3
        with:
          dependency-versions: ${{ matrix.dependency-versions }}

      - run: composer test:with-coverage
        if: ${{ matrix.coverage == 'xdebug' }}

      - run: composer test:without-coverage
        if: ${{ matrix.coverage != 'xdebug' }}
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
