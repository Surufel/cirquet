import Foundation
import Vapor
import VaporPostgreSQL
import Auth
import HTTP


let socket = Droplet(
    preparations: [User.self, Message.self, Venue.self],
    providers: [VaporPostgreSQL.Provider.self]
)

socket.post("login") {
    request in
    let googleid = request.data["googleid"]?.string!
    var str: String = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=" + String(googleid!)
    let res = try socket.client.post(str)
    var sub = res.json?["sub"]?.double!
    if res.status.statusCode == 200 {
        let u = try User.query().filter("googleid", sub!).first()
        if u != nil {
            return try JSON(
                node: [
                    "is_host": u!.host,
                    "sender_name": u?.fname,
                    "sender_id": u!.hashedid,
                    "exists": true
                ]
            )
        }
        return try JSON(node: [
            "exists": false
            ])
    }
    
    throw Abort.custom(status: .badRequest, message: "Invalid google token")
    
}



socket.post("register") {
    request in
    //Pull in data from the request sent from the app
    let fname = request.data["fname"]?.string!
    let lname = request.data["lname"]?.string!
    let email = request.data["email"]?.string!
    let age = request.data["age"]?.int!
    let host = request.data["host"]?.bool!
    let googleid = request.data["googleid"]?.string!
    //let date = Double((request.data["date"]?.string!)!)
    print(request.data["date"]?.double)
    

    
    //Send a request to google to authenticate the token received from the app
    var str: String = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=" + String(googleid!)
    let res = try socket.client.post(str)
    var sub = res.json?["sub"]?.double!
    var hu = try socket.hash.make(String(sub!))
    
    
    
    
    if(res.status.statusCode == 200) {
        //If google responds with 200 OK, extract json as dictionary
                //Create credentials variable as UserData object
        
        if (try User.query().filter("googleid", sub!).first()) != nil {
            throw Abort.custom(status: .badRequest, message: "User already exists in db, try logging in instead.")
        }
        else {
            var u: User = User(fname: fname!, lname: lname!, email: email!, age: age!, host: host!, googleid: sub!, signupdate: 4434234, tokenexpiry: "99999", hashedid: hu)
            try u.save()
            var x = try JSON(node: [
                "is_host": u.host,
                "sender_name": u.fname,
                "sender_id": u.hashedid,
                "exists": true
                ])
            print(x)
            return x
        }
        
    }
    

// This return will never happen, but Xcode wants it so Xcode is happy :)
    throw Abort.custom(status: .badRequest, message: "Invalid google credentials sent to server")


}
socket.post("get-message") {
    request in
    let time = request.data["time"]?.double!
    let gid = request.data["id"]?.string!
    let cid = request.data["cid"]?.string!
    if try User.query().filter("hashedid", gid!).first() != nil {
        if let x: JSON? = try JSON(node: Message.query().filter("date", .greaterThan, time!).filter("chat", cid!).all().makeNode()) {
            return x!
        }
        else {
            return "no messages"
        }
    }
    
    return "ok"
    
}

socket.post("get-chat") {
    request in
    let cid = request.data["cid"]?.string!
    if let x: Venue? = try Venue.query().filter("chatid", cid!).first() {
        return x!.chatname
    }
    else {
        throw Abort.custom(status: .badRequest, message: "Invalid chat code")
    }
}

socket.post("last5") {
    req in
    let cid = req.data["cid"]?.string!
    if let x: [Message]? = try Message.query().filter("date", .greaterThan, Date().timeIntervalSince1970-300).filter("chat", cid!).all() {
        return try JSON((x?.makeNode())!)
    }
    else {
        return "no new messages"
    }
}

socket.post("message") {
    request in
    let msg = request.data["msg"]?.string!
    let date = request.data["date"]?.string!
    let id = request.data["id"]?.string!
    let chat = request.data["chat"]?.string!
    
    var m = Message(contents: msg!.truncated(to: 255), owner: id!, date: Double(date!)!, chat: chat!)
    //print(try m.makeNode())
    try m.save()
    //print(m.exists)
    if m.exists {
        return try JSON(node: [
            "success": true
            ])
    }
    else {
        throw Abort.custom(status: .badRequest, message: "User does not exist in db. Unable to send message.")
    }

    
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





socket.run()

