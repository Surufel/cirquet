//
//  User.swift
//  cirquet
//
//  Created by Kurt Bitner on 11/15/16.
//
//

import Foundation
import Vapor

final class User: Model {
    var id: Node?
    var exists: Bool = false
    var fname: String
    var lname: String
    var email: String
    var age: Int
    var host: Bool
    var googleid: String
    
    init(fname: String, lname: String, email: String, age: Int, host: Bool, googleid: String) {
        self.id = nil
        self.fname = fname
        self.lname = lname
        self.email = email
        self.age = age
        self.host = host
        self.googleid = googleid
    }
    
    init(node: Node, in context: Context) throws {
        self.id = try node.extract("id")
        self.fname = try node.extract("fname")
        self.lname = try node.extract("lname")
        self.email = try node.extract("email")
        self.age = try node.extract("age")
        self.host = try node.extract("host")
        self.googleid = try node.extract("googleid")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": self.id,
            "fname": self.fname,
            "lname": self.lname,
            "email": self.email,
            "age": self.age,
            "host": self.host,
            "googleid": self.googleid
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("users") {
            users in
            users.id()
            users.string("fname")
            users.string("lname")
            users.string("email")
            users.int("age")
            users.bool("host")
            users.string("googleid")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
}
