Guard
=====
A fluent, chainable validation and assertion library for Luau. Designed for clean, readable code and precise Studio autocomplete.

INSTALLATION
------------
Drop the `Guard.luau` script into your ReplicatedStorage or ServerScriptService, then require it:

    local Guard = require(path.to.Guard)

QUICK START
-----------
    local username = "  CoolDev99  "

    local cleanName = Guard(username)
        :Exists()
        :Transform(function(v) return v:match("^%s*(.-)%s*$") end)
        .StringGuard
        :MinLength(3)
        :Alphanumeric()
        :UnwrapOr("Guest")

    print(cleanName) --> Output: CoolDev99

FEATURES
--------
- Fluent Chaining: Combine general methods (:Exists(), :Custom(), :Transform()) and type-specific rules seamlessly.
- Live Proxies: State changes and mutations propagate dynamically across the whole chain.
- Safety & Error Handling: Use :Assert() for guard clauses, or :UnwrapOr() / :Unwrap() for safe data retrieval.
- Supported Types: Strings, Numbers, Booleans, Instances, Tables, and Functions.
