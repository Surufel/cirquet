import Foundation
import Vapor

final class Message: Model {
    
    var id: Node?
    var exists: Bool = false
    
    var contents: String
    var owner: String
    var name: String
    var date: Double
    var chat: String
    
    init(contents: String, owner: String, name: String, date: Double, chat: String) {
        self.id = nil
        self.contents = contents
        self.owner = owner
        self.name = name
        self.date = date
        self.chat = chat
    }
    init(node: Node, in context: Context) throws {
        self.id = try node.extract("id")
        self.contents = try node.extract("contents")
        self.owner = try node.extract("owner")
        self.name = try node.extract("name")
        self.date = try node.extract("date")
        self.chat = try node.extract("chat")
    }
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": self.id,
            "contents": self.contents,
            "owner": self.owner,
            "name": self.name,
            "date": self.date,
            "chat": self.chat
            ])
    }
    static func prepare(_ database: Database) throws {
        try database.create("messages", closure: {
            messages in
            messages.id()
            messages.string("contents")
            messages.string("owner")
            messages.string("name")
            messages.double("date")
            messages.string("chat")
        })
    }
    static func revert(_ database: Database) throws {
        try database.delete("messages")
    }
    
}
