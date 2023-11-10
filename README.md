Redmine Unregistered Watchers plugin
======================

This Redmine plugin allows us to add watchers to issues when these users are not registered.
These watchers will only be notified when the selected status are updated.

The related module must be activated for each project.
The email addresses of the unregistered watchers are specified in each issue.
A new panel in the project settings allows to select which status update generates an email to these unregister watchers.
Content of the generated email is also specified in the project settings.

It is possible to insert variables in the emails sent to the watchers.
Just surround issue's attributes with curly brackets {issue_attribute}.
Examples:

    Standard attributes:
    {id}
    {status}
    {subject}
    {tracker}
    {priority}
    {fixed_version}
    {created_on}
    etc.
    
    To display dates with time, just add "with_time" after the attribute name, like this:
    {created_on_with_time}
    {updated_on_with_time}

    Custom fields:
    by id: {cf_5}
    by name: {cf_name_of_the_field} (replace spaces by underscores)

    Special attributes:
    {last_note}
    {magic_link_*magic-link-rule-id*} (Only available if the magic-link plugin is installed)

The previous syntax using greater and less signs (like <<tracker>> or <<last_note>>) is deprecated and does not provide as much attributes.
 
Installation
------------

This plugin has been tested with Redmine 2.5.0+.

Requirements:

    ruby >= 2.1.0

Please apply general instructions for plugins [here](http://www.redmine.org/wiki/redmine/Plugins).

Note that this plugin now depends on these other plugins:

* **redmine_base_deface** [here](https://github.com/jbbarth/redmine_base_deface)
* **redmine_base_select2** [here](https://github.com/jbbarth/redmine_base_select2)

First download the source or clone the plugin and put it in the "plugins/" directory of your redmine instance. Note that this is crucial that the directory is named redmine_unregistered_watchers !

Then execute:

    $ bundle install
    $ rake redmine:plugins

And finally restart your Redmine instance.

Test status
-----------

|Plugin branch| Redmine Version   | Test Status      |
|-------------|-------------------|------------------|
|master       | 4.2.11            | [![4.2.11][1]][5]|
|master       | 5.1.0             | [![5.1.0][2]][5] |
|master       | master            | [![master][4]][5]|

[1]: https://github.com/nanego/redmine_unregistered_watchers/actions/workflows/4_2_11.yml/badge.svg
[2]: https://github.com/nanego/redmine_unregistered_watchers/actions/workflows/5_1_0.yml/badge.svg
[4]: https://github.com/nanego/redmine_unregistered_watchers/actions/workflows/master.yml/badge.svg
[5]: https://github.com/nanego/redmine_unregistered_watchers/actions


Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
