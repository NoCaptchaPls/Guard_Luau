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

HOW IT WORKS & CRITICAL DETAILS
-------------------------------
1. Chaining and Namespaces:
   You can run base methods directly off the initial wrapper (like `:Exists()` or `:Transform()`). 
   When you need type-specific checks, you must access the matching namespace (e.g., `.StringGuard`, `.NumberGuard`, `.InstanceGuard`, etc.).

2. The Need for a Finalizer:
   Accessing a namespace like `.StringGuard` or running intermediate checks switches your context or returns the internal guard tracking object. 
   If you try to `print()` the guard mid-chain, you will just get a table reference (e.g., `table: 0x...`). 
   
   To get an actual answer or value out of your chain, you **must end it with a finalizer**:
   - `:IsValid()` -> Returns `true` or `false` based on whether all rules passed.
   - `:IsInvalid()` -> Returns `true` if any rule failed.
   - `:Assert([msg])` -> Throws a Luau error immediately if the check fails (great for guard clauses).
   - `:Unwrap()` -> Returns the final value if valid, or errors out if invalid.
   - `:UnwrapOr(fallback)` -> Returns the final value if valid, or returns your fallback value if invalid.

EXAMPLES
--------
Checking a boolean or length condition using a finalizer (`:IsValid()`):
    local isShort = Guard(player.Name)
        .StringGuard
        :MaxLength(3)
        :IsValid()

    print(isShort) --> true or false

Stopping execution immediately using `:Assert()`:
    local function setScore(score)
        Guard(score)
            .NumberGuard
            :NonNegative()
            :Assert("Score cannot be negative!")
    end

FEATURES
--------
- Fluent Chaining: Combine general methods and type-specific rules seamlessly.
- Live Proxies: State changes and mutations propagate dynamically across the whole chain.
- Safety & Error Handling: Use `:Assert()` for guard clauses, or `:UnwrapOr()` / `:Unwrap()` for safe data retrieval.
- Supported Types: Strings, Numbers, Booleans, Instances, Tables, and Functions.
