module UnregisteredWatchersHelper
  def email_body_with_variables(issue, body)
    body.gsub( /<<\S*>>/) { |match| get_value(issue, match.gsub('<<', '').gsub('>>', '').to_sym) }
  end

  def get_value(issue, attribute)
    begin
      value = issue.try(attribute)
      if attribute == :created_at
        value = Time.now if value.blank?
      end
      if value.present?
        if value.is_a?(Time)
          value.to_date.to_s
        else
          value.to_s
        end
      else
        ""
      end
    rescue
      ""
    end
  end
end
