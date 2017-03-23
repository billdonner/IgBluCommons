import PackageDescription

let package = Package(
    name: "IgBluCommons",
    targets: [
        Target(name: "IgBluCommons", dependencies: [])
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 6),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1),
        .Package(url: "https://github.com/IBM-Bluemix/cf-deployment-tracker-client-swift.git", majorVersion: 2),
        .Package(url: "https://github.com/IBM-Swift/Kitura-Request.git", majorVersion: 0)
    ],
    exclude: ["Makefile", "Package-Builder"])
