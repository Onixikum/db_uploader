require 'pg'
require 'csv'
namespace :upload_data do
  desc 'Import posts from a CSV file into a database using copy'
  task import_posts: :environment do
    DB_NAME = 'db_uploader_development'
    DB_USER = ''
    DB_PASSWORD = ''
    DB_HOST = 'localhost'
    DB_PORT = 5432
    TABLE_NAME = 'posts'
    FILE_PATH = '/posts_test_data.csv'

    conn = PG.connect(dbname: DB_NAME, user: DB_USER, password: DB_PASSWORD, host: DB_HOST, port: DB_PORT)

    begin
      # Clearing table before import... if it needs
      conn.exec("TRUNCATE #{TABLE_NAME};")

      # Disabling triggers...
      conn.exec("ALTER TABLE #{TABLE_NAME} DISABLE TRIGGER ALL;")

      # Importing data from CSV...
      conn.copy_data("COPY #{TABLE_NAME} (user_id, description, accept, test_user, created_at, updated_at) FROM STDIN WITH CSV HEADER") do
        File.foreach(FILE_PATH) do |line|
          conn.put_copy_data(line.strip + ",#{Time.now.strftime('%Y-%m-%d %H:%M:%S')},#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\n")
        end
      end

      # Enabling triggers...
      conn.exec("ALTER TABLE #{TABLE_NAME} ENABLE TRIGGER ALL;")
      puts 'Import completed successfully!'
    rescue PG::Error => e
      puts "Import error: #{e.message}"
    ensure
      conn.close
    end
  end
end
