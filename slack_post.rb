require 'slack-notifier'

class SlackPost
  def initialize(webhook_url, bot_name)
    @webhook_url = webhook_url
    @notifier = Slack::Notifier.new @webhook_url do
      defaults username: bot_name
    end
  end

  def post(text, **options)
    @notifier.post text: text, **options
  end
end
