use Rack::Static,
  :urls => ["/img", "/js", "/css", '/index.html'],
  :root => "public"

require './app'

run WeSoc::API