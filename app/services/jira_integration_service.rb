# Service class to handle communication with JIRA
class JIRAIntegrationService
  class << self
    def create_issue(user_id, feedback_params)
      user = User.find(user_id)
      feedback_params.deep_symbolize_keys!
      session_token = authenticate!
      payload = build_payload(user, feedback_params)
      faraday_connection.post do |req|
        req.url TahiEnv.jira_create_issue_url
        req.body = payload.to_json
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.headers['Cookie'] = "JSESSIONID=#{session_token[:value]}"
      end
    end

    def authenticate!
      credentials = {
        username: TahiEnv.jira_username,
        password: TahiEnv.jira_password
      }
      auth_response = faraday_connection.post do |req|
        req.url TahiEnv.jira_authenticate_url
        req.body = credentials.to_json
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
      end
      auth_response_body = JSON.parse auth_response.body, symbolize_names: true
      raise if auth_response_body[:session].blank?
      auth_response_body[:session]
    end

    def build_payload(user, feedback_params)
      description = feedback_params[:remarks] + "\n\n"
      description += "Referrer: #{feedback_params[:referrer]} \n"
      description += "User Email: #{user.email} \n"
      description += "Attachments:\n#{attachment_urls(feedback_params)}" if attachments_exist?(feedback_params)
      description += "\n\n"
      fields = {
        summary: "Aperta Feedback from #{user.full_name}.",
        description: description,
        customfield_13500: user.username,
        customfield_13501: feedback_params[:browser],
        customfield_13502: feedback_params[:platform],
        customfield_13503: 'Some Fake DOI',

        project: {
          key: TahiEnv.jira_project
        },
        components: [{
          name: "Aperta"
        }],
        issuetype: {
          name: "Feedback"
        }
      }

      { fields: fields }
    end

    def attachment_urls(feedback_params)
      result = ''
      feedback_params.dig(:screenshots).each do |screenshot|
        result += screenshot[:url] + "\n"
      end
      result
    end

    def attachments_exist?(feedback_params)
      feedback_params.key?(:screenshots)
    end

    def faraday_connection
      @faraday_connection ||= Faraday.new do |faraday|
        faraday.request  :url_encoded
        faraday.response :logger
        faraday.adapter  Faraday.default_adapter
      end
    end
  end
end
