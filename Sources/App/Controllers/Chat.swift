import Vapor

class Chat {
    var conns: [String: WebSocket]
    func bot(_ message: String) throws {
        try send(name: "Bot", message: message)
    }
    
    func send(name: String, message: String) throws {
        let message = message.truncated(to: 255)
        let js = try JSON(node: [
                "username": name,
                "message": message
            ])
        for (username, socket) in conns {
            guard username != name else {
                continue
            }
            try socket.send(js.makeNode().string!)
        }
    }
    init() {
        conns = [:]
    }
}
