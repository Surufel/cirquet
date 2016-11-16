import Foundation
import Vapor

final class Message: Model {
    
    var id: Node?
    var exists: Bool = false
    
    var contents: String
    var owner: Int
    var date: String
    var chat: String
    
    init(contents: String, owner: Int, date: String, chat: String) {
        self.id = nil
        self.contents = contents
        self.owner = owner
        self.date = date
        self.chat = chat
    }
    init(node: Node, in context: Context) throws {
        self.id = try node.extract("id")
        self.contents = try node.extract("contents")
        self.owner = try node.extract("owner")
        self.date = try node.extract("date")
        self.chat = try node.extract("chat")
    }
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": self.id,
            "contents": self.contents,
            "owner": self.owner,
            "date": self.date,
            "chat": self.chat
            ])
    }
    static func prepare(_ database: Database) throws {
        try database.create("messages", closure: {
            messages in
            messages.id()
            messages.string("contents")
            messages.int("owner")
            messages.string("date")
            messages.string("chat")
        })
    }
    static func revert(_ database: Database) throws {
        try database.delete("messages")
    }
    
}
