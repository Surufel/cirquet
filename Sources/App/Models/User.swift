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
import Turnstile
import TurnstileWeb

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
    var hashedid: String
    
    init(credentials: Credentials) throws {
        self.id = nil
        switch credentials{
            case let credentials as Array<Any>:
                self.fname = credentials[1] as! String
                self.lname = credentials[2] as! String
                self.email = credentials[3] as! String
                self.age = credentials[4] as! Int
                self.host = credentials[5] as! Bool
                self.googleid = Double((credentials[0] as! GoogleAccount).uniqueID)!
                self.signupdate = credentials[6] as! Double
                self.hashedid = try Droplet().hash.make((credentials[0] as! GoogleAccount).uniqueID)
            
            default:
                throw UnsupportedCredentialsError()
        }
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
        self.hashedid = try node.extract("hashedid")
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
            "hashedid": self.hashedid
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
            users.string("hashedid")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
    
}

extension User: Auth.User {
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        var u: User
        
        switch credentials {
        case let credentials as Array<Any>:
            var g = credentials[0]
            switch g {
            case let g as GoogleAccount:
                if let us = try User.query().filter("googleid", g.uniqueID).first() {
                    u = us;
                }
                else {
                    u = try User.register(credentials: credentials as! Credentials) as! User
                    //return u
                }
            default:
                throw IncorrectCredentialsError()
                
            }
            default:
                throw UnsupportedCredentialsError()
    }
            
            
        
        if u.exists {
            return u
        } else {
            throw IncorrectCredentialsError()
        }
        
    }
    static func register(credentials: Credentials) throws -> Auth.User {
        var nu: User
        switch credentials {
        case let credentials as Array<Any>:
            let gacc = credentials[0]
            switch gacc {
            case let gacc as GoogleAccount:
                if try User.query().filter("googleid", gacc.uniqueID).first() == nil {
                    nu = try User(credentials: credentials as! Credentials)
                    try nu.save()
                    return nu
                    
            }
            default:
                throw AccountTakenError()
            }
        default:
            throw IncorrectCredentialsError()
        }
        
        
    }
}

//extension User: Auth.User {
//    static func authenticate (credentials: Credentials) throws -> Auth.User {
//
//        //Check db if user exists
//        let user = try User.query().filter("googleid", (credentials as! User).googleid).first()
//        
//        if user != nil {
//            // If y != nil we will return user
//            return user!
//        }
//        
//        else {
//            throw Abort.custom(status: .badRequest, message: "User does not exist")
//        }
//
//    }
//    
//    static func register (credentials: Credentials) throws -> Auth.User {
//        
//        // Check db if user exists
//        let user = try User.query().filter("googleid", (credentials as! User).googleid).first()
//        if user != nil {
//            // If user exists, throw abort & main .swift will continue to try to login
//            print("user already exists")
//            throw Abort.custom(status: .badRequest, message: "User already exists")
//            
//        }
//        else {
//            print("register")
//            var us = credentials as! User //Casting credentials back to User class since User conforms to Credentials protocol
//            try us.save() //save user to db
//            if us.exists {
//                return us
//            }
//            else {
//                throw Abort.custom(status: .badRequest, message: "Unable to save user")
//            }
//        }
//    }
//    
//}







