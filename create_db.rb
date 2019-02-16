require './pg_util.rb'

host = ENV.fetch('ARXIV_BOT_POSTGRES_HOST', 'localhost')
user = ENV.fetch('ARXIV_BOT_POSTGRES_USER', 'postgres')
connection_string = ENV.fetch('DATABASE_URL', nil)

conn_info = if connection_string
              { connection_string: connection_string }
            else
              { host: host, user: user }
            end
pgutil = PgUtil.new('arxiv_bot', conn_info)
pgutil.drop_db
pgutil.create_db
