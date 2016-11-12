import Vapor
//import VaporPostgreSQL


let drop = Droplet()
//try drop.addProvider(VaporPostgreSQL.Provider.self);

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

drop.get("test1") {
    request in
    return "123456"
}
drop.get ("12345") {
    request in
    return "hi1"
}
drop.socket("ws") { req, ws in
    print("New WebSocket connected: \(ws)")
    
    try ws.send("connected");
    
}


drop.run()
