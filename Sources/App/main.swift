import Foundation
import Vapor
//probably import chat file
import VaporPostgreSQL



let socket = Droplet(
    preparations: [User.self, Message.self],
    providers: [VaporPostgreSQL.Provider.self]
)

socket.get { req in
    return try socket.view.make("welcome", [
    	"message": socket.localization[req.lang, "welcome", "title"]
    ])
}

socket.get("hi") {
    request in
    return try socket.view.make("hi.html")
}


//drop.resource("posts", PostController())



socket.socket("ws") { req, ws in
    print("New WebSocket connected: \(ws)")
    
    // ping the socket to keep it open
    try background {
        while ws.state == .open {
            try? ws.ping()
            socket.console.wait(seconds: 10) // every 10 seconds
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



socket.post("register") {
    request in
    let fname = request.data["fname"]?.string!
    let lname = request.data["lname"]?.string!
    let email = request.data["email"]?.string!
    let age = request.data["age"]?.int!
    let host = request.data["host"]?.bool!
    let googleid = request.data["googleid"]?.string!
    let date = Double((request.data["date"]?.string!)!)
    var u = User(fname: fname!, lname: lname!, email: email!, age: age!, host: host!, googleid: googleid!, signupdate: date!)
    try u.save()
    return "ok"
    

}

socket.post("message") {
    request in
    let msg = request.data["msg"]?.string!
    let date = request.data["date"]?.string!
    let id = request.data["id"]?.int!
    let chat = request.data["chat"]?.string!
    var m = Message(contents: msg!, owner: id!, date: date!, chat: chat!)
    try m.save()
    return try JSON(node: Message.all().makeNode())
    
}
// chat functions here


socket.run()
