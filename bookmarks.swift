import Mustache
import Taylor


let bookmarks = [
    ["url": "https://github.com", "title": "GitHub"],
    ["url": "https://twitter.com", "title": "Twitter"],
]


// Given a list of bookmarks, return the HTML required to render
// them as a list.
func HTMLforListOfBookmarks(bookmarks: [[String: String]]) -> String {
    let data = [
        "bookmarks": bookmarks,
    ]

    do {
        let template = try Template(path: "./template.html")
        return try template.render(Box(data))
    } catch {
        // This isn't great error handling -- we should really send
        // an error 500 status code.  Also, this error message is
        // unhelpfully generic.  Improve this!
        print("Error rendering the page.")
        return "Server error."
    }
}


let server = Taylor.Server()

server.get("/") { req, res in
    res.bodyString = HTMLforListOfBookmarks(bookmarks)
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