//
// bookmarks.swift
//
// Created by Alex Chan on 11 June 2016
//

import Foundation

import Mustache
import Taylor

let PLISTPATH = "./bookmarks.plist"


func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return (lhs.compare(rhs) == NSComparisonResult.OrderedDescending)
}


func getBookmarks() -> [Bookmark] {
    if let retval = NSArray(contentsOfFile: PLISTPATH) {
        let bookmarks = retval.map { dictToBookmark($0 as! NSDictionary) }
        return bookmarks.sort {$0.date_added < $1.date_added}
    } else {
        return [Bookmark]()
    }
}


func setBookmarks(data: [Bookmark]) {
    let array = NSArray(array: data.map {$0.encode()})
    array.writeToFile(PLISTPATH, atomically: true)
}


struct Bookmark {
    var uuid: String
    var url: String
    var title: String
    var description: String?
    var date_added: NSDate
    var tags: [String]?

    func encode() -> NSDictionary {
        let metadata = NSMutableDictionary()

        metadata.setObject(self.uuid, forKey: "uuid")
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

    func has_tag(tag: String) -> Bool {
        if tags == nil {
            return false
        } else {
            return tags!.contains(tag)
        }
    }
}


// Yes, this is horrible and repetitive.  It helps deserialise the
// obejcts that come out of the plist file.
func dictToBookmark(dict: NSDictionary) -> Bookmark {
    let uuid: String
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

    if let new_uuid = dict["uuid"] {
        uuid = String(new_uuid)
    } else {
        uuid = NSUUID().UUIDString
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

    return Bookmark(uuid: uuid,
                    url: url,
                    title: title,
                    description: description,
                    date_added: date_added,
                    tags: tags)
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


func HTMLFormForNewBookmark() -> String {
    do {
        let template = try Template(path: "./form.html")
        return try template.render()
    } catch {
        // This isn't great error handling -- we should really send
        // an error 500 status code.  Also, this error message is
        // unhelpfully generic.  Improve this!
        print("Error rendering the page.")
        return "Server error."
    }
}


let server = Taylor.Server()
server.addHandler(Middleware.requestLogger { print($0) })

server.get("/") { req, res, cb in
    res.bodyString = HTMLforListOfBookmarks(getBookmarks(), title: "")
    res.headers["Content-Type"] = "text/html"
    return cb(.Send(req, res))
}

server.get("/add") { req, res, cb in
    res.bodyString = HTMLFormForNewBookmark()
    res.headers["Content-Type"] = "text/html"
    return cb(.Send(req, res))
}

server.post("/add", Middleware.bodyParser(), { req, res, cb in

    // Tags are entered space-separated by the user, so turn them into
    // a list of strings.
    let tags: [String]?
    if let tagString = req.body["tags"] {
        tags = tagString.characters.split{$0 == " "}.map(String.init)
    } else {
        tags = nil
    }

    let description = String(req.body["description"]!)

    // Create the new bookmark and add it to the list
    let new_bookmark = Bookmark(uuid: NSUUID().UUIDString,
                                url: String(req.body["url"]!),
                                title: String(req.body["title"]!),
                                description: description,
                                date_added: NSDate(),
                                tags: tags)
    var bookmarks = getBookmarks()
    bookmarks.append(new_bookmark)
    setBookmarks(bookmarks)

    // Send a bit of JS to close the 'New bookmark' window
    res.bodyString = "<script>window.close();</script>"
    res.headers["Content-Type"] = "text/html"

    return cb(.Send(req, res))
})

server.get("/style.css") { req, res, cb in
    res.bodyString = try! String(contentsOfURL: NSURL(fileURLWithPath: "style.css"),
                                 encoding: NSUTF8StringEncoding)
    res.headers["Content-Type"] = "text/css"
    return cb(.Send(req, res))
}


let port = 8080
do {
   print("Starting server on port: \(port)")
   try server.serveHTTP(port: port, forever: true)
} catch {
   print("Server start failed \(error)")
}