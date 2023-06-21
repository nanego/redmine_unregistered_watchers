module UnregisteredWatchersHelper
  def email_body_with_variables(issue, body)
    # Deprecated variables (using <<...>> syntax)
    body.gsub!(/<<\S*>>/) { |match| issue_attribute_value(issue, match.delete_prefix('<<').delete_suffix('>>')) }

    # variables using {...} syntax
    body.gsub!(/{[[:word:]]*}/) do |attribute|
      attribute = attribute.delete_prefix("{").delete_suffix("}")
      case attribute
      when /^cf_\d+/
        custom_field_value_by_id(issue, attribute.delete_prefix("cf_"))
      when /^cf_[[:word:]]*/
        custom_field_value_by_name(issue, attribute.delete_prefix("cf_"))
      when /^magic_link_\d/
        magic_link_for_unregistered_watchers(issue, attribute.delete_prefix("magic_link_"))
      when /[[:word:]]*_with_time$/
        issue_attribute_value(issue, attribute.delete_suffix("_with_time"), with_time: true)
      else
        issue_attribute_value(issue, attribute)
      end
    end

    body
  end

  def custom_field_value_by_id(issue, cf_id)
    cf = IssueCustomField.where(id: cf_id).first
    cf.present? ? issue.custom_field_value(cf) : ""
  end

  def custom_field_value_by_name(issue, cf_name)
    cf = IssueCustomField.where("lower(name) = ? ", cf_name.humanize.downcase).first
    cf.present? ? issue.custom_field_value(cf) : ""
  end

  def issue_attribute_value(issue, attribute, with_time: false)
    if issue.respond_to?(attribute.downcase.to_sym)
      value = issue.send(attribute.downcase.to_sym)
      if value.is_a?(Date) || value.is_a?(Time)
        with_time ? format_time(value) : format_date(value)
      else
        value
      end
    end
  end

  def magic_link_for_unregistered_watchers(issue, rule_id)
    if Redmine::Plugin.installed?(:redmine_magic_link)
      rule = MagicLinkRule.where(id: rule_id, enabled: true, enabled_for_unregistered_watchers: true).first
      if rule.present?
        magic_link_hash = issue.add_magic_link_hash(rule)
        rule.log_new_link_sent(issue)
        Rails.application.routes.url_helpers.url_for(controller: 'issues',
                                                     action: 'show',
                                                     id: issue.id,
                                                     issue_key: magic_link_hash,
                                                     host: Mailer.default_url_options[:host],
                                                     only_path: false)
      end
    end
  end

end
