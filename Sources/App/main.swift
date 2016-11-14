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
    
    // ping the socket to keep it open
    try background {
        while ws.state == .open {
            try? ws.ping()
            drop.console.wait(seconds: 10) // every 10 seconds
        }
    }
    
    ws.onText = { ws, text in
        print("Text received: \(text)")
        
        // reverse the characters and send back
        let rev = String(text.characters.reversed())
        try ws.send(rev)
    }
    
    ws.onClose = { ws, code, reason, clean in
        print("Closed.")
    }
}

drop.post("register") {
    request in
    return (request.parameters["fullName"]?.string)!;
}


drop.run()
