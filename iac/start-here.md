# Init Project
1. **Make `composer.json` dependencies fixed.**
    * [Great article](https://mikemadison.net/blog/2020/11/17/configuring-php-version-with-composer) on `php` as a dependency
    * [Great article](https://berlinonline.github.io/php-introduction/chapters/namespaces_and_autoloading/) on `autoload`
      * [Further reading](https://getcomposer.org/doc/04-schema.md#autoload) on the types of autoloading the `autoload` property supports
      * [Another useful article](https://getcomposer.org/doc/01-basic-usage.md#autoloading) on the `autoload` property
      * [A StackOverflow answer](https://stackoverflow.com/a/38736351) on `autoload` and the `optimize-autoloader` config associated with it
   * `scripts`
      * [`scripts` lifecycle commands](https://getcomposer.org/doc/articles/scripts.md#command-events) docs 
      * `post-update-cmd` is basically saying, on `dev` environments, make sure Laravel's files get published
    * `composer create-project` is the same as `git clone` & `composer install`
    * The `preferred-install` config is [very interesting](https://getcomposer.org/doc/06-config.md#preferred-install)
   * [These](https://stackoverflow.com/a/33052243) [are](https://stackoverflow.com/a/44759879) both great answers on `composer update` vs `composer install`
     * Run `composer update`. (Remember: run `composer install` on deployed environments)
2. **Make `package.json` dependencies fixed.**
3. **Place `/private` in `.gitignore`**
4. **Delete `composer.lock` and `vendor/`**
5. **Delete `package-lock.json` and `node_modules`**

# IaC
1. Create:
   * `/compose.yml` file
   * `/iac/local` directory
2. Copy:
   * `/private/resources/compose-template.yml` to `/compose.yml` (and replace all `<< >>`)
   * `/private/resources/php8-3.Dockerfile` to `/iac/local/<< project name >>.Dockerfile` (and replace all `<< >>`)
   * `/private/resources/supervisord.conf` to `/iac/local/supervisord.conf`
   * `/private/resources/php.ini` to `/iac/local/php.ini`
