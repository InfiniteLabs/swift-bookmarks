//
// bookmarks.swift
//
// Created by Alex Chan on 11 June 2016
//

import Foundation

import Mustache
import Taylor

let PLISTPATH = "./bookmarks.plist"


func getBookmarks() -> [Bookmark] {
    if let retval = NSArray(contentsOfFile: PLISTPATH) {
        return retval.map { dictToBookmark($0 as! NSDictionary) }
    } else {
        return [Bookmark]()
    }
}


func setBookmarks(data: [Bookmark]) {
    let array = NSArray(array: data.map {$0.encode()})
    array.writeToFile(PLISTPATH, atomically: true)
}


struct Bookmark {
    var url: String
    var title: String
    var description: String?
    var date_added: NSDate
    var tags: [String]?

    func encode() -> NSDictionary {
        let metadata = NSMutableDictionary()

        metadata.setObject(self.url, forKey: "url")
        metadata.setObject(self.title, forKey: "title")
        metadata.setObject(self.date_added, forKey: "date_added")

        // Only add the optional fields if they are non-nil.
        if let description = self.description {
            metadata.setObject(description, forKey: "description")
        }
        if let tags = self.tags {
            metadata.setObject(tags, forKey: "tags")
        }

        return metadata
    }
}


// Yes, this is horrible and repetitive.  It helps deserialise the
// obejcts that come out of the plist file.
func dictToBookmark(dict: NSDictionary) -> Bookmark {
    let url: String
    let title: String
    let date_added: NSDate
    let tags: [String]?
    let description: String?

    if let new_url = dict["url"] {
        url = String(new_url)
    } else {
        print("Missing URL on \(dict); exiting.")
        exit(1)
    }

    if let new_title = dict["title"] {
        title = String(new_title)
    } else {
        print("Missing title on \(dict); exiting.")
        exit(1)
    }

    if let new_date = dict["date_added"] {
        date_added = (new_date as! NSDate)
    } else {
        date_added = NSDate()
    }

    if let new_tags = dict["tags"] {
        tags = (new_tags as? [String])!.sort()
    } else {
        tags = nil
    }

    if let new_description = dict["description"] {
        description = (new_description as! String)
    } else {
        description = nil
    }

    return Bookmark(url: url, title: title, description: description,
                    date_added: date_added, tags: tags)
}


// Given a list of bookmarks, return the HTML required to render
// them as a list.
func HTMLforListOfBookmarks(bookmarks: [Bookmark], title: String) -> String {
    let data = [
        "bookmarks": bookmarks.map {$0.encode()},
        "title": title,
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
    res.bodyString = HTMLforListOfBookmarks(getBookmarks(), title: "")
    res.headers["Content-Type"] = "text/html"
    return .Send
}
    res.headers["Content-Type"] = "text/html"
    return .Send
}

server.get("/style.css") { req, res in
    res.bodyString = try! String(contentsOfURL: NSURL(fileURLWithPath: "style.css"),
                                 encoding: NSUTF8StringEncoding)
    res.headers["Content-Type"] = "text/css"
    return .Send
}


let port = 8080
do {
   print("Starting server on port: \(port)")
   try server.serveHTTP(port: port, forever: true)
} catch {
   print("Server start failed \(error)")
}