import Taylor


// Set up a data structure for handling bookmarks.
struct Bookmark {
    let url: String
    let title: String
}

let bookmarks = [
    Bookmark(url: "https://github.com", title: "GitHub"),
    Bookmark(url: "https://twitter.com", title: "Twitter"),
]


let server = Taylor.Server()

server.get("/") { req, res in

    var bodyString = "<html><body><p>My bookmarks:</p><ul>"
    for bookmark in bookmarks {
        bodyString += "<li><a href=\"\(bookmark.url)\">\(bookmark.title)</li>"
    }
    bodyString += "</ul></html>"

    res.bodyString = bodyString
    res.headers["Content-Type"] = "text/html"
    return .Send
}


let port = 8080
do {
   print("Starting server on port: \(port)")
   try server.serveHTTP(port: port, forever: true)
} catch {
   print("Server start failed \(error)")
}