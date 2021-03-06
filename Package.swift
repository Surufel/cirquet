import PackageDescription

let package = Package(
    name: "cirquet",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/vapor/postgresql-provider.git", majorVersion: 1, minor: 0),
	.Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", versions: Version(1,0,0)..<Version(15, .max, .max))
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
        "Tests",
    ]
)

