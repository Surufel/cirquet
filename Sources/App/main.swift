import Foundation
import Vapor
import VaporPostgreSQL
import Auth
import HTTP


let socket = Droplet(
    preparations: [User.self, Message.self],
    providers: [VaporPostgreSQL.Provider.self]
)



socket.post("register") {
    request in
    //Pull in data from the request sent from the app
    let fname = request.data["fname"]?.string!
    let lname = request.data["lname"]?.string!
    let email = request.data["email"]?.string!
    let age = request.data["age"]?.int!
    let host = request.data["host"]?.bool!
    let googleid = request.data["googleid"]?.string!
    let date = Double((request.data["date"]?.string!)!)
    

    
    //Send a request to google to authenticate the token received from the app
    var str: String = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=" + String(googleid!)
    let res = try socket.client.post(str)
    var sub = res.json?["sub"]?.double!
    var exp = res.json?["exp"]?.string!
    var hu = try socket.hash.make(String(sub!))
    
    
    
    
    if(res.status.statusCode == 200) {
        //If google responds with 200 OK, extract json as dictionary
                //Create credentials variable as UserData object
        var u: User = User(fname: fname!, lname: lname!, email: email!, age: age!, host: host!, googleid: sub!, signupdate: date!, tokenexpiry: exp!, hashedid: hu)
            //First try register
            do {
                try _ = User.register(credentials: u)
            } catch _ {
        //If user exists, we will continue to login
            }
            do {
//                print("login")
//                print(creds.token)
                try _ = User.authenticate(credentials: u)
                return try JSON(node: [
                    "success": true
                    ])
            } catch _ {
                print("catch")
                throw Abort.custom(status: .badRequest, message: "invalid google id")
            }
    
    }
    

// This return will never happen, but Xcode wants it so Xcode is happy :)
    return "ok"

}
socket.get("get-message") {
    request in
    let time = request.data["time"]?.double!
    let gid = request.data["id"]?.string!
    let cid = request.data["cid"]?.string!
    var str: String = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token" + gid!
    var sub: String  = ""
    let res = try socket.client.post(str)
    if res.status.statusCode == 200 {
        sub = (res.json?["sub"]?.string!)!
        if try User.query().filter("googleid", sub).first() != nil {
            return try JSON(node: Message.query().filter("date", .greaterThan, time!).filter("chat", cid!).all().makeNode())
        }
    }
    return "ok"
    
}

socket.post("message") {
    request in
    let msg = request.data["msg"]?.string!
    let date = request.data["date"]?.double!
    let id = request.data["id"]?.string!
    let chat = request.data["chat"]?.string!
    let u = try User.query().filter("id", id!).first()
    var m = Message(contents: msg!, owner: id!, date: date!, chat: chat!)
    try m.save()
    if m.exists {
    return try JSON(node: [
        "success": true
        ])
    }
    

    throw Abort.custom(status: .badRequest, message: "User does not exist in db. Unable to send message.")
}

socket.post("get-id") {
    request in
    
    let gid = request.data["gid"]?.string!

    var str: String = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=" + gid!
    let res = try socket.client.post(str)
    var sub: Double = 0
    if res.status.statusCode == 200 {
        print("hi")
        sub = (res.json?["sub"]?.double!)!
        print(sub)
        var u: User? = try User.query().filter("googleid", sub).first()
        print(try User.query().filter("googleid", sub).first())
        if u != nil {
            
            return (u?.hashedid)!
            
        }
    }
    throw Abort.custom(status: .badRequest, message: "User does not exist in db. Unable to get id.")
}

// chat functions here
//let chat = Chat()
//
//
//socket.socket("ws") { req, ws in
//    var name: String? = nil
//    
//    ws.onText = {
//        ws, text in
//        let js = try JSON(bytes: Array(text.utf8))
//        if let u = js.object?["username"]?.string {
//            name = u
//            chat.conns[u] = ws
//            try chat.bot("\(u) has joined")
//        }
//        if let u = name, let m = js.object?["message"]?.string {
//            try chat.send(name: u, message: m)
//        }
//    }
//    ws.onClose = {
//        ws, _, _, _ in
//        guard let u = name else {
//            return
//        }
//        try chat.bot("\(u) has left")
//        chat.conns.removeValue(forKey: u)
//    }
//}



socket.run()

