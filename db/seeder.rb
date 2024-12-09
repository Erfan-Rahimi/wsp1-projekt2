require 'sqlite3'

class Seeder
  
  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS fruits')
    db.execute('DROP TABLE IF EXISTS users')
  end

  def self.create_tables
    db.execute('CREATE TABLE fruits (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                tastiness INTEGER,
                description TEXT)')
    db.execute('CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL)')
  end

  def self.populate_tables
    db.execute('INSERT INTO fruits (name, tastiness, description) VALUES ("Äpple",   7, "En rund frukt som finns i många olika färger.")')
    db.execute('INSERT INTO fruits (name, tastiness, description) VALUES ("Päron",    6, "En nästan rund, men lite avläng, frukt. Oftast mjukt fruktkött.")')
    db.execute('INSERT INTO fruits (name, tastiness, description) VALUES ("Banan",  4, "En avlång gul frukt.")')
    password_hashed = BCrypt::Password.create("123")
    p "Storing hashed version of password to db. Clear text never saved. #{password_hashed}"
    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', ["ola", password_hashed])
  end

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/fruits.sqlite')
    @db.results_as_hash = true
    @db
  end
end


Seeder.seed!