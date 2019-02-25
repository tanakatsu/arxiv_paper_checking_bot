require 'yaml'
require 'erb'
require 'json'
require 'date'
require './send_gmail.rb'
require './slack_post.rb'
require './arxiv_api.rb'
require './pg_util.rb'

class ArxivBot
  def initialize(setting_file = 'settings.yml')
    @db_name = 'arxiv_bot'
    @table_name = 'histories'
    @history_file = 'histories.json'

    @setting_file = setting_file
    @settings = read_setting(@setting_file)
    if @settings['store']['connection_string']
      conn_info = { connection_string: @settings['store']['connection_string'] }
    else
      conn_info = { host: @settings['store']['host'], user: @settings['store']['user'] }
    end
    @pgutil = PgUtil.new(@db_name, conn_info)
    @histories = read_history
    @arxiv_api_client = ArxivApi.new

    @mailer = gmail_available? ? SendGmail.new(@settings['channel']['gmail']['user_name'], @settings['channel']['gmail']['password']) : nil
    @slack = slack_available? ? SlackPost.new(@settings['channel']['slack']['webhook_url'], @settings['channel']['slack']['bot_name']) : nil

    puts 'channel: Gmail is on' if @mailer
    puts 'channel: Slack is on' if @slack
  end

  def do_check
    has_histories = !@histories.empty?
    entries = @arxiv_api_client.search(@settings['keywords'], @settings['api']['max_results'])
    puts "Get #{entries.length} entries"
    entries.each do |entry|
      next if check_history(entry[:id])
      puts "Found new paper: #{entry[:id]}"

      url = entry[:id]
      title = entry[:title]
      summary = entry[:summary]

      subject = "New paper: #{title}"
      body = "#{url}\n\n#{summary}"

      if @mailer && has_histories
        @mailer.deliver(@settings['channel']['gmail']['from'],
                        @settings['channel']['gmail']['to'],
                        subject, body)
      end
      if @slack && has_histories
        options = symbolize(@settings['channel']['slack']['options'])
        @slack.post("#{subject}\n#{body}", **options)
      end

      insert_history(url: url, checked_at: Time.now)
    end
    puts 'check done.'
  end

  private

  def read_setting(filename)
    yaml = YAML.safe_load(ERB.new(File.read(filename)).result)
    yaml
  end

  def db_available?
    @settings['store']['connection_string'] || (@settings['store']['db_host'] && @settings['store']['db_user'])
  end

  def read_history
    db_available? ? read_history_from_db : read_history_from_file
  end

  def insert_history(entry)
    if db_available?
      insert_history_to_db(entry)
    else
      insert_history_to_file(entry)
    end
  end

  def read_history_from_file
    return [] unless File.exist?(@history_file)
    json_str = open(@history_file).read
    return [] if json_str.empty?

    JSON.parse(json_str)
  end

  def insert_history_to_file(entry)
    @histories.push(entry)
    open(@history_file, 'w') do |f|
      JSON.dump(@histories, f)
    end
  end

  def read_history_from_db
    histories = @pgutil.select(@table_name)
    histories
  end

  def insert_history_to_db(entry)
    @histories.push(entry)
    @pgutil.insert(@table_name, %w(url checked_at),
                   [entry[:url], entry[:checked_at].to_s])
  end

  def check_history(url)
    @histories.find { |h| h['url'] == url }
  end

  def gmail_available?
    gmail_setting = @settings['channel']['gmail']
    gmail_setting['user_name'] && gmail_setting['password']
  end

  def slack_available?
    @settings['channel']['slack']['webhook_url']
  end

  def symbolize(h)
    Hash[h.map { |k, v| [k.to_sym, v] }]
  end
end

bot = ArxivBot.new
bot.do_check
