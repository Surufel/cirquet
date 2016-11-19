import Foundation
import Vapor
import VaporPostgreSQL
import Auth



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




socket.post("register") {
    request in
    let fname = request.data["fname"]?.string!
    let lname = request.data["lname"]?.string!
    let email = request.data["email"]?.string!
    let age = request.data["age"]?.int!
    let host = request.data["host"]?.bool!
    let googleid = request.data["googleid"]?.string!
    let date = Double((request.data["date"]?.string!)!)
//    var creds = [fname!, lname!, email!, String(age!), String(host!), googleid!, String(date!)] as [String]
//    var v: AccessToken = AccessToken(string: googleid!)
//    try _ = User.register(credentials: creds as! Credentials)
//    do {
//       try request.auth.login(v)
//        print("login")
//        return try JSON(node: [
//            "success": true
//            ])
//    } catch _ {
//        throw Abort.custom(status: .badRequest, message: "invalid google id")
//    }

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
let chat = Chat()


socket.socket("ws") { req, ws in
    var name: String? = nil
    
    ws.onText = {
        ws, text in
        let js = try JSON(bytes: Array(text.utf8))
        if let u = js.object?["username"]?.string {
            name = u
            chat.conns[u] = ws
            try chat.bot("\(u) has joined")
        }
        if let u = name, let m = js.object?["message"]?.string {
            try chat.send(name: u, message: m)
        }
    }
    ws.onClose = {
        ws, _, _, _ in
        guard let u = name else {
            return
        }
        try chat.bot("\(u) has left")
        chat.conns.removeValue(forKey: u)
    }
}


socket.run()
