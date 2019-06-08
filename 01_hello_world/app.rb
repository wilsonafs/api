require 'sinatra'
require "sinatra/reloader"

get '/hello' do
    'Hello world'
end

get '/json' do
    content_type :json

    '{"message": "Hello world"}'
end

get '/par-impar/' do
    content_type :json

    halt(422, '{ "erro" : "Entre um numero" }')
end

get '/par-impar/:numero' do |numero|
    content_type :json

    numero_inteiro = Integer(numero)
    if numero_inteiro % 2 == 0
        '{"valor": "par"}'
    else
        '{"valor": "impar"}'
    end
rescue ArgumentError => e
    halt(400, '{ "erro" : "Parametro invalido" }')
end