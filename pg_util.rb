require 'pg'

class PgUtil
  def initialize(database, conn_info = { host: 'localhost', user: 'postgres', password: nil, port: 5432, connection_string: nil })
    @database = String(database)
    @host = conn_info[:host]
    @user = conn_info[:user]
    @password = conn_info[:password]
    @port = conn_info[:port]
    @connection_string = conn_info[:connection_string]
  end

  def create_db
    connect_db('postgres')
    @conn.exec("CREATE DATABASE #{@database}")
    puts 'Finished creating database.'
  rescue PG::Error => e
    puts e.message
  ensure
    @conn.close if @conn
  end

  def drop_db
    connect_db('postgres')
    @conn.exec("DROP DATABASE IF EXISTS #{@database}")
    puts 'Finished dropping database.'
  rescue PG::Error => e
    puts e.message
  ensure
    @conn.close if @conn
  end

  def create_table(table, schema)
    connect_db
    schema_str = schema.map { |k, v| "#{k} #{v}" }.join(', ')
    @conn.exec("CREATE TABLE #{table} (id serial PRIMARY KEY, #{schema_str});")
    puts 'Finished creating table.'
  rescue PG::Error => e
    puts e.message
  ensure
    @conn.close if @conn
  end

  def drop_table(table)
    connect_db
    @conn.exec("DROP TABLE IF EXISTS #{table};")
    puts 'Finished dropping table.'
  rescue PG::Error => e
    puts e.message
  ensure
    @conn.close if @conn
  end

  def insert(table, columns, data)
    connect_db
    column_data = columns.join(', ')
    input_data = data.map { |d| d.is_a?(String) ? "'#{d}'" : d }.join(', ')
    @conn.exec("INSERT INTO #{table} (#{column_data}) VALUES(#{input_data});")
    puts 'Inserted 1 rows of data.'
  rescue PG::Error => e
    puts e.message
  ensure
    @conn.close if @conn
  end

  def delete_by_id(table, id)
    connect_db
    @conn.exec("DELETE FROM #{table} WHERE id = #{id};")
    puts 'Deleted 1 row of data.'
  rescue PG::Error => e
    puts e.message
  ensure
    @conn.close if @conn
  end

  def select(table, options = {})
    connect_db
    order_clause = if options[:order]
                     o = options[:order]
                     o.start_with?('-') ? "order by #{o[1..o.size]} desc" : "order by #{o}"
                   else
                     nil
                   end
    limit_clause = options[:limit] ? "limit #{options[:limit]}" : ''
    results = @conn.exec("SELECT * from #{table} #{order_clause} #{limit_clause};")
    # res_data = []
    # results.each do |res|
    #   res_data << res
    # end
    # res_data
    results.inject([]) { |data, res| data << res }
  rescue PG::Error => e
    puts e.message
  ensure
    @conn.close if @conn
  end

  private

  def connect_db(database = nil)
    target_db = database ? database : @database
    @conn = if @connection_string
              PG::Connection.new(@connection_string)
            else
              PG::Connection.new(host: @host, user: @user, dbname: target_db,
                                 port: @port, password: @password)
            end
    # puts 'Successfully created connection to database'
  end
end
