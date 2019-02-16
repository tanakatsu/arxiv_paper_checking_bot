require './pg_util.rb'

host = ENV.fetch('ARXIV_BOT_POSTGRES_HOST', 'localhost')
user = ENV.fetch('ARXIV_BOT_POSTGRES_USER', 'postgres')

pgutil = PgUtil.new('arxiv_bot', host, user)
pgutil.drop_db
pgutil.create_db
pgutil.create_table('histories', url: 'VARCHAR(255)', checked_at: 'TIMESTAMP')
