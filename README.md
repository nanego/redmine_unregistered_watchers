Redmine Unregistered Watchers plugin
======================

This Redmine plugin allows us to add watchers that are not registered. These watchers will only be notify when selected status are updated.

This new module can be activate by project.
Then, for each issue, we specify the emails of the unregistered watchers.
A new panel in the project settings make it possible de specify which issue status generate an email to these unregister watchers. It's also there that we specify the content of the email generated regarding the new issue status.


Installation
------------

This plugin has been tested with Redmine 2.5.0+.

Please apply general instructions for plugins [here](http://www.redmine.org/wiki/redmine/Plugins).

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
