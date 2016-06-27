module UnregisteredWatchersHelper
  def email_body_with_variables(issue, body)
    updated_body = body.gsub( /<<.*>>/) do |match|
      begin
        match = match.gsub('<<', '').gsub('>>', '').to_sym
        value = @issue.try(match)
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
    updated_body
  end
end
