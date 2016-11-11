import Vapor

let drop = Droplet()
print(drop.workDir)

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.get("hi") {
    request in
    return try drop.view.make("hi.html")
}

drop.get("test") {
    request in
    return "hi12345"
}

//drop.resource("posts", PostController())



drop.run()
