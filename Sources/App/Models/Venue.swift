import Vapor

final class Venue: Model {
    var id: Node?
    var exists: Bool = false
    
    var host: String
    var latitude: Double
    var longitude: Double
    var name: String
    var address: String
    var city: String
    var state: String
    var zip: Int
    var chatname: String
    var chatid: String
    
    init(host: String, latitude: Double, longitude: Double, name: String, address: String, city: String, state: String, zip: Int, chatname: String, chatid: String) {
        self.host = host
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.zip = zip
        self.chatname = chatname
        self.chatid = chatid
    }
    init(node: Node, in context: Context) throws {
        self.id = try node.extract("id")
        self.host = try node.extract("host")
        self.latitude = try node.extract("latitude")
        self.longitude = try node.extract("longitude")
        self.name = try node.extract("name")
        self.address = try node.extract("address")
        self.city = try node.extract("city")
        self.state = try node.extract("state")
        self.zip = try node.extract("zip")
        self.chatname = try node.extract("chatname")
        self.chatid = try node.extract("chatid")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": self.id,
            "host": self.host,
            "latitude": self.latitude,
            "longitude": self.longitude,
            "name": self.name,
            "address": self.address,
            "city": self.city,
            "state": self.state,
            "zip": self.zip,
            "chatname": self.chatname,
            "chatid": self.chatid
            ])
    }
    static func prepare(_ database: Database) throws {
        try database.create("venues", closure: {
            venues in
            venues.id()
            venues.string("host")
            venues.double("latitude")
            venues.double("longitude")
            venues.string("name")
            venues.string("address")
            venues.string("city")
            venues.string("state")
            venues.int("zip")
            venues.string("chatname")
            venues.string("chatid")
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
    
    
}
