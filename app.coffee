restify = require('restify')
path = require('path')
nodeStatic = require('node-static')
http = require('http')

staticServers = {}
staticServerPort = 9200

startStaticServer = (dirname) ->
  staticServerPort += 1
  fileServer = new nodeStatic.Server(dirname)
  staticServer = {
    port: staticServerPort
    dirname: dirname
    fileServer: fileServer
    httpServer: http.createServer( (request, response) ->
        request.addListener('end', ->
            fileServer.serve(request, response)
        ).resume()
    )
  }
  staticServer.httpServer.listen(staticServer.port)
  console.log("started static server on port #{staticServer.port} for #{dirname}")
  return staticServer

staticServerForPort = (port)->
  for dirname, staticServer of staticServers
    if staticServer.port == port
      return staticServer

respond = (req, res, next) -> 

  fullpath = req.path()
  dirname = path.dirname(fullpath)
  basename = path.basename(fullpath)

  if not staticServers[dirname]?
    console.log('todo: start server')
    staticServers[dirname] = startStaticServer(dirname)

  staticServer = staticServers[dirname]

  res.header('Location', "http://127.0.0.1:#{staticServer.port}/#{basename}")
  res.send(302)
  next()

server = restify.createServer()

server.get('/_servers', (req, res, next)->
  list = ( {port: v.port, dirname: v.dirname} for k,v of staticServers)
  res.send(200, list)
  next()
)

server.del('/_servers/:port', (req, res, next)->
  port = parseInt(req.params.port)
  staticServer = staticServerForPort(port)
  if staticServer
    console.log("killing static server on port #{port}")
    staticServer.httpServer.close(->
      delete staticServers[staticServer.dirname]
      res.send(204)
      next()
    )
  else 
    console.log("no static server found for port #{port}")
    res.send(404)
    next()
)

server.get(/(.*)/, respond)
server.head(/(.*)/, respond)

# http://127.0.0.1:9123/Users/luke/Desktop/foo/index.html
# http://127.0.0.1:9200/index.html

server.listen(9123, "127.0.0.1", ->
  console.log('%s listening at %s', server.name, server.url)
)