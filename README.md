# docs-sitemap

This is a simple tool to build a sitemap index for [Crystal API docs](https://crystal-lang.org/api).

See https://github.com/crystal-lang/crystal-website/issues/79 for details.

* it queries the index file for each API version on https://crystal-lang.org/api
* it extracts each link from the navigation menu
* the links for each version are placed in a separate sitemap file and given a
  specific priority depending on how recent the version is
* references to all sitemaps are collected in a sitemap index file

## Usage

```shell
> crystal run src/app.cr
```

The program generates the individual sitemap files in `output/sitemaps/` and the
sitemap index at `output/sitemap-index.xml.gz`.

## Contributing

1. Fork it (<https://github.com/straight-shoota/crystal_docs_sitemap/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Johannes Müller](https://github.com/straight-shoota) - creator and maintainer
