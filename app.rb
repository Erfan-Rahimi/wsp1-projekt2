class App < Sinatra::Base

    # Funktion som returnerar en databaskoppling
    # Exempel på användning: db.execute('SELECT * FROM fruits')
    def db
        return @db if @db

        @db = SQLite3::Database.new("db/fruits.sqlite")
        @db.results_as_hash = true

        return @db
    end
    
    # Routen gör en redirect till '/fruits'
    get '/' do
        redirect('/fruits')
    end

    # Routen hämtar alla frukter i databasen
    get '/fruits' do
        @fruits = db.execute('SELECT * FROM fruits')
        p @fruits
        erb(:"fruits/index")
    end

    # Routen visar ett formulär för att spara en ny frukt till databasen.
    get '/fruits/new' do 
        erb(:"fruits/new")
    end

    # Routen raderar en frukt från databasen och gör en redirect till '/fruits'.
    post '/fruits/:id/delete' do | id |

        # Använder en parameteriserad fråga för att förhindra SQL-injektion
        db.execute("DELETE FROM fruits WHERE id = ?", [id])
      
        # Optionellt, gör en redirect eller rendera något efter radering
        redirect '/fruits'
    end

    # Routen visar formuläret för att redigera en frukt
    get '/fruits/:id/edit' do |id|
        @fruit = db.execute('SELECT * FROM fruits WHERE id=?', id).first
        erb :"fruits/edit"  # Renderar redigeringsformuläret
    end
  
    # Routen hanterar formulärets inskickning för att uppdatera en frukt
    post '/fruits/:id/update' do |id|
        name = params[:fruit_name]
        description = params[:fruit_description]
        tastiness = params[:fruit_tastiness]
    
        # Uppdatera frukten i databasen
        db.execute("UPDATE fruits SET name = ?, description = ?, tastiness = ? WHERE id = ?", [name, description, tastiness, id])
    
        # Gör en redirect till fruktlistan efter uppdatering
        redirect '/fruits'
    end
    

    # Routen sparar en ny frukt till databasen och gör en redirect till '/fruits'.
    post '/fruits' do

        name = params[:fruit_name]
        description = params[:fruit_description]
        tastiness = params[:fruit_tastiness]
      
        # Debugging för att kontrollera parametrar
        p params
      
        # Lägg till frukten i databasen
        db.execute("INSERT INTO fruits (name, description, tastiness) VALUES(?,?,?)", [name, description,tastiness])
      
        redirect '/fruits'
          
    end

    # Routen visar all info (från databasen) om en frukt.
    get '/fruits/:id' do | id |
        # Hämta data från databasen för den specifika frukten med hjälp av id
        @fruit = db.execute('SELECT * FROM fruits WHERE id=?', id).first
        erb(:"fruits/show")
    end

    # Allt dessa är för att kunna logga in 
    
    configure do
        enable :sessions
        set :session_secret, SecureRandom.hex(64)
      end
    
      get '/' do
        if session[:user_id]
          erb(:"admin/index")
        else
          erb :index
        end
      end
    
      post '/testpwcreate' do
        plain_password = params[:plainpassword]
        password_hashed = BCrypt::Password.create(plain_password)
        p password_hashed
      end
    
      get '/admin' do
        if session[:user_id]
          erb(:"admin/index")
        else
          p "/admin : Access denied."
          status 401
          redirect '/unauthorized'
        end
      end
    
      get '/unauthorized' do
        erb(:unauthorized)
      end
    
      post '/login' do
        request_username = params[:username]
        request_plain_password = params[:password]
    
        user = db.execute("SELECT *
                FROM users
                WHERE username = ?",
                request_username).first
    
        unless user
          p "/login : Invalid username."
          status 401
          redirect '/unauthorized'
        end
    
        db_id = user["id"].to_i
        db_password_hashed = user["password"].to_s
    
        # Create a BCrypt object from the hashed password from db
        bcrypt_db_password = BCrypt::Password.new(db_password_hashed)
        # Check if the plain password matches the hashed password from db
        if bcrypt_db_password == request_plain_password
          p "/login : Logged in -> redirecting to admin"
          session[:user_id] = db_id
          redirect '/admin'
        else
          p "/login : Invalid password."
          status 401
          redirect '/unauthorized'
        end
    
      end
    
      get '/logout' do
        p "/logout : Logging out"
        session.clear
        redirect '/'
      end

end
