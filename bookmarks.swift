import Taylor


let server = Taylor.Server()

server.get("/") { req, res in
    res.bodyString = "Hello world!"
    return .Send
}


let port = 8080
do {
   print("Starting server on port: \(port)")
   try server.serveHTTP(port: port, forever: true)
} catch {
   print("Server start failed \(error)")
}