import PackageDescription

let package = Package(
    name: "cirquet",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/vapor/postgresql-provider.git", majorVersion: 1, minor: 0),
	.Package(url: "https://github.com/JustHTTP/Just.git", majorVersion: 0, minor: 5)
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

