module UnregisteredWatchersHelper
  def email_body_with_variables(issue, body)
    # Deprecated variables (using <<...>> syntax)
    body.gsub!( /<<\S*>>/) { |match| issue_attribute_value(issue, match.delete_prefix('<<').delete_suffix('>>')) }

    # variables using {...} syntax
    body.gsub!(/{[[:word:]]*}/) do |attribute|
      attribute = attribute.delete_prefix("{").delete_suffix("}")
      case attribute
      when /^cf_\d+/
        custom_field_value_by_id(issue, attribute.delete_prefix("cf_"))
      when /^cf_[[:word:]]*/
        custom_field_value_by_name(issue, attribute.delete_prefix("cf_"))
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

  def issue_attribute_value(issue, attribute)
    issue.send(attribute.downcase.to_sym) if issue.respond_to?(attribute.downcase.to_sym)
  end

end
