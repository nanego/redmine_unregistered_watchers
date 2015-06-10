Redmine Unregistered Watchers plugin
======================

This Redmine plugin allows us to add watchers to issues when these users are not registered. These watchers will only be notified when the selected status are updated.

This new module can be activated by project.
For each issue, we specify the email addresses of the unregistered watchers.
A new panel in the project settings make it possible de specify which status update generate an email to these unregister watchers. It's also in the project settings that we specify the content of the email generated regarding the new issue status.


Installation
------------

This plugin has been tested with Redmine 2.5.0+.

Please apply general instructions for plugins [here](http://www.redmine.org/wiki/redmine/Plugins).

Note that this plugin now depends on this other plugin:

* **redmine_base_deface** [here](https://github.com/jbbarth/redmine_base_deface)

First download the source or clone the plugin and put it in the "plugins/" directory of your redmine instance. Note that this is crucial that the directory is named redmine_unregistered_watchers !

Then execute:

    $ bundle install
    $ rake redmine:plugins

And finally restart your Redmine instance.


Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
