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
    let htmlComponents = [
        "<!DOCTYPE html>",
        "<html lang=\"en\">",
        "<head>",

        // Mobile resizing magic
        "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",

        // Link to Bootstrap stylesheet
        "<link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css\">",

        "</head>",
        "<body><div class=\"container\">\(bodyString)</div></body>",
        "</html>",
    ]
    return htmlComponents.joinWithSeparator("")
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