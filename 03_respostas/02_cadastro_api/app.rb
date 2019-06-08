require 'sinatra'
require 'redis'
require 'json'
require 'cpf_cnpj'
require 'sinatra/reloader'
require 'byebug' 

redis = Redis.new(url: "redis://localhost:6379")

get '/bem-vindo' do
  content_type :json

  '{"mensagem": "Bem vindo ao QA Sampa Meeting"}'
end

get '/usuarios' do
  content_type :json

  "[" + redis.hvals('usuarios').join(',') + "]"
end

get "/usuarios/:id" do
  content_type :json

  id = params["id"]
  resposta = redis.hget("usuarios", id)
  halt(404, { message:'Usuario nao encontrato'}.to_json) if resposta.nil?
  resposta
end

post '/usuarios' do
  content_type :json

  usuario = JSON.parse(request.body.read)

  nome = usuario.fetch('nome', nil)
  cpf = usuario.fetch('cpf', nil)
  email = usuario.fetch('email', nil)
  nascimento = usuario.fetch('nascimento', nil)

  id = redis.incr('id_users')
  usuario['id'] = id
  headers 'Location' => "/users/#{usuario['id']}"

  # validations
  halt(401, { message:'Nome nao pode estar em branco'}.to_json) if nome.nil?
  halt(401, { message:'CPF nao pode esta em branco'}.to_json) if cpf.nil?
  #halt(401, { message:'CPF invalido'}.to_json)unless CPF.valid?(cpf, strict: true)
  halt(401, { message:'Email nao pode estar em branco'}.to_json) if email.nil?
  halt(401, { message:'Nascimento nao pode estar em branco'}.to_json) if nascimento.nil?
  begin
    Date.iso8601(nascimento)
  rescue ArgumentError => e
    halt(401, { message:'Nascimento nao esta em formato ISO8601 yyyy-mm-dd'}.to_json)
  end
  
  redis.hset('usuarios', id, JSON.dump(usuario))
  201
end

delete '/usuarios/:id' do
  id = params['id']
  redis.hdel('usuarios', id)
  204
end

put '/usuarios/:id' do
  content_type :json

  usuario = JSON.parse(request.body.read)

  id = params['id']
  nome = usuario.fetch('nome', nil)
  cpf = usuario.fetch('cpf', nil)
  email = usuario.fetch('email', nil)
  nascimento = usuario.fetch('nascimento', nil)

  # validations
  halt(401, { message:'Nome nao pode estar em branco'}.to_json) if nome.nil?
  halt(401, { message:'CPF nao pode esta em branco'}.to_json) if cpf.nil?
  #halt(401, { message:'CPF invalido'}.to_json)unless CPF.valid?(cpf, strict: true)
  halt(401, { message:'Email nao pode estar em branco'}.to_json) if email.nil?
  halt(401, { message:'Nascimento nao pode estar em branco'}.to_json) if nascimento.nil?
  begin
    Date.iso8601(nascimento)
  rescue ArgumentError => e
    halt(401, { message:'Nascimento nao esta em formato ISO8601 yyyy-mm-dd'}.to_json)
  end
  
  redis.hset('usuarios', id, JSON.dump(usuario))
  204
end