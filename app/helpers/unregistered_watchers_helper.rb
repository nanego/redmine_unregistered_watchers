module UnregisteredWatchersHelper
  def email_body_with_variables(issue, body)
    updated_body = body.gsub( /<<.*>>/) do |match|
      begin
        match = match.gsub('<<', '').gsub('>>', '').to_sym
        value = @issue.try(match)
        if value.present?
          value.to_s
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
