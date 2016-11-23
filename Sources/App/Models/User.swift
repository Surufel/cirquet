//
//  User.swift
//  cirquet
//
//  Created by Kurt Bitner on 11/15/16.
//
//

import Foundation
import Vapor
import Auth

final class User: Model, Credentials {
    var id: Node?
    var exists: Bool = false
    var fname: String
    var lname: String
    var email: String
    var age: Int
    var host: Bool
    var googleid: Double
    var signupdate: Double
    var tokenexpiry: Double
    
    init(fname: String, lname: String, email: String, age: Int, host: Bool, googleid: Double, signupdate: Double, tokenexpiry: String) {
        self.id = nil
        self.fname = fname
        self.lname = lname
        self.email = email
        self.age = age
        self.host = host
        self.googleid = googleid
        self.signupdate = signupdate
        self.tokenexpiry = Double(tokenexpiry)!
    }
    
    init(node: Node, in context: Context) throws {
        self.id = try node.extract("id")
        self.fname = try node.extract("fname")
        self.lname = try node.extract("lname")
        self.email = try node.extract("email")
        self.age = try node.extract("age")
        self.host = try node.extract("host")
        self.googleid = try node.extract("googleid")
        self.signupdate = try node.extract("signupdate")
        self.tokenexpiry = try node.extract("tokenexpiry")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": self.id,
            "fname": self.fname,
            "lname": self.lname,
            "email": self.email,
            "age": self.age,
            "host": self.host,
            "googleid": self.googleid,
            "signupdate": self.signupdate,
            "tokenexpiry": self.tokenexpiry
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
            users.double("googleid")
            users.double("signupdate")
            users.double("tokenexpiry")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
    
}

extension User: Auth.User {
    static func authenticate (credentials: Credentials) throws -> Auth.User {
        
        //Check db if user exists
        let user = try User.query().filter("googleid", (credentials as! User).googleid).first()
        
        if user != nil {
            // If y != nil we will return user
            return user!
        }
        
        else {
            throw Abort.custom(status: .badRequest, message: "User does not exist")
        }

    }
    
    static func register (credentials: Credentials) throws -> Auth.User {
        
        // Check db if user exists
        let user = try User.query().filter("googleid", (credentials as! User).googleid).first()
        if user != nil {
            // If user exists, throw abort & main .swift will continue to try to login
            print("user already exists")
            throw Abort.custom(status: .badRequest, message: "User already exists")
            
        }
        else {
            print("register")
            var us = credentials as! User //Casting credentials back to User class since User conforms to Credentials protocol
            try us.save() //save user to db
            return us // return user
        }
    }
    
}





