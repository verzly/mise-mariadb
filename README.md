# verzly/mise-mariadb

> [!IMPORTANT]
> The plugin requires a MISE installation to be used. <a href="https://github.com/jdx/mise#quickstart" target="_blank">Go to Quickstart</a>

## Why is version control of MariaDB useful?

Sometimes, certain updates introduce changes that break scripts that previously worked. We need to be able to quickly roll back to a previous version. We should be able to make multiple versions available on our system simultaneously. We must be able to preserve databases intact and centrally manage the server’s start and stop methods, its availability, and the location where the data is stored.

## Get started

```none
# Install the plugin
mise plugin install mariadb https://github.com/verzly/mise-mariadb

# Install/Select version globally
mise use -g mariadb@11

# Install/Select version locally (for current directory)
cd /path/to/mariadb/project
mise use mariadb@10.6
```

## Up-to-date

```none
# Upgrade plugin to latest version instantly
mise plugin upgrade mariadb
```

## Contributing

```none
# Link your plugin for development
mise plugin link mariadb /path/to/verzly/mise-mariadb
```

## License

This project is a plugin created for MISE by [Zoltán Rózsa](https://github.com/rozsazoltan) under the [GNU Affero General Public License v3.0 (AGPL-3.0)](https://www.gnu.org/licenses/agpl-3.0.html).

Copyright (C) 2020–present [Zoltán Rózsa](https://github.com/rozsazoltan) & [Verzly](https://github.com/verzly)

This version is licensed under the AGPL-3.0.  
For full license terms, see the [LICENSE](./LICENSE) file.

## Credits

This project is made possible by much love and the other open source software.

## Thanks

Appreciation goes to [GitHub Actions](https://github.com/features/actions) for enabling a dependable continuous integration system, which has been essential throughout the development process.

Finally, a heartfelt thank you to the broader [open-source](https://github.com/open-source) community and to the maintainers of the libraries used in this project. Your ongoing efforts make projects like this possible.

**Motivation:** Because _together_, nothing is impossible.
