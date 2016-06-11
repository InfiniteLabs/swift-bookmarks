import Mustache
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


// Given the HTML body for a page, add the <html> and <head> content.
func HTMLfromBody(bodyString: String) -> String {
    do {
        let template = try Template(path: "./template.html")
        return try template.render(Box(["bodyString": bodyString]))
    } catch {
        // This isn't great error handling -- we should really send
        // an error 500 status code.  Also, this error message is
        // unhelpfully generic.  Improve this!
        print("Error rendering the page.")
        return "Server error."
    }
}


// Given an array of Bookmarks, return the HTML required to list those
// bookmarks on the page.
func indexPage(bookmarks: [Bookmark]) -> String {
    var bodyString = "<p>My bookmarks:</p><ul>"
    for bookmark in bookmarks {
        bodyString += "<li><a href=\"\(bookmark.url)\">\(bookmark.title)</li>"
    }
    bodyString += "</ul>"
    return HTMLfromBody(bodyString)
}


let server = Taylor.Server()

server.get("/") { req, res in
    res.bodyString = indexPage(bookmarks)
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