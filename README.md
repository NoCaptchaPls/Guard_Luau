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

COMPLETE API REFERENCE
======================

This section explains every guard type and the functions you can use. 

1. BASE FUNCTIONS (Works on any Guard)
--------------------------------------
These can be used right after `Guard(value)` before picking a specific type.

- :Exists([message])
  Checks if the value is not nil.
  Example: Guard(player):Exists():Assert()

- :Equals(expected, [message])
  Checks if the value is equal to the expected value.
  Example: Guard(status):Equals("Active"):IsValid()

- :NotEquals(expected, [message])
  Checks if the value is NOT equal to the expected value.
  Example: Guard(role):NotEquals("Banned"):IsValid()

- :OneOf(list, [message])
  Checks if the value matches one of the items inside a list table.
  Example: Guard(team):OneOf({"Red", "Blue"}):IsValid()

- :Optional()
  If the value is nil, this skips all the checks that come after it instead of failing.
  Example: Guard(nickname):Optional().StringGuard:MinLength(3):IsValid()

- :Default(fallback)
  If the value is nil, this replaces it with a backup value and keeps checking.
  Example: Guard(score):Default(0).NumberGuard:NonNegative():Unwrap()

- :Custom(predicateFn, [message])
  Runs your own custom check function. Returns true if your function passes.
  Example: Guard(num):Custom(function(v) return v % 5 == 0 end):IsValid()

- :Transform(transformerFn)
  Changes the value into something else using a function.
  Example: Guard(text):Transform(function(v) return v:lower() end):Unwrap()

- :Type(expectedType, [message])
  Checks the basic Lua type (using type()).
  Example: Guard(x):Type("string"):IsValid()

- :TypeOf(expectedType, [message])
  Checks the advanced Roblox type (using typeof(), like "Instance" or "Vector3").
  Example: Guard(part):TypeOf("Instance"):IsValid()

- :IsValid()
  Finalizer. Returns true if all checks passed, or false if any failed.
  Example: local ok = Guard(x):Exists():IsValid()

- :IsInvalid()
  Finalizer. Returns true if any check failed.
  Example: local bad = Guard(x):Exists():IsInvalid()

- :Error()
  Returns the first error message if the check failed.
  Example: local err = Guard(x):Exists():Error()

- :GetErrors()
  Returns a list of all error messages.
  Example: local allErrs = Guard(x):GetErrors()

- :Assert([message])
  Finalizer. Throws a script error immediately if the checks failed.
  Example: Guard(health):NumberGuard:NonNegative():Assert("Health cannot be negative!")

- :Unwrap()
  Finalizer. Returns the final value if it passed, or throws an error if it failed.
  Example: local safeVal = Guard(input):Exists():Unwrap()

- :UnwrapOr(fallback)
  Finalizer. Returns the final value if it passed, or gives you a safe backup value if it failed.
  Example: local final = Guard(input).StringGuard:MinLength(3):UnwrapOr("Guest")


2. STRING GUARD (.StringGuard)
------------------------------
Used for checking text.

- :Length(min, max, [message])
  Checks if the text length is between min and max.
  Example: Guard(name).StringGuard:Length(3, 10):IsValid()

- :MinLength(min, [message])
  Checks if the text is at least a certain length.
  Example: Guard(name).StringGuard:MinLength(3):IsValid()

- :MaxLength(max, [message])
  Checks if the text is no longer than a certain limit.
  Example: Guard(bio).StringGuard:MaxLength(100):IsValid()

- :Empty([message])
  Checks if the text is completely empty ("").
  Example: Guard(input).StringGuard:Empty():IsValid()

- :NotEmpty([message])
  Checks if the text has actual characters in it.
  Example: Guard(input).StringGuard:NotEmpty():IsValid()

- :Pattern(luaPattern, [message])
  Checks if the text matches a Lua pattern.
  Example: Guard(email).StringGuard:Pattern("^[%w]+@[%w]+%.[%w]+$"):IsValid()

- :Contains(substring, [message])
  Checks if the text contains a specific word or letter.
  Example: Guard(chat).StringGuard:Contains("hello"):IsValid()

- :StartsWith(prefix, [message])
  Checks if the text starts with specific letters.
  Example: Guard(cmd).StringGuard:StartsWith("!"):IsValid()

- :EndsWith(suffix, [message])
  Checks if the text ends with specific letters.
  Example: Guard(filename).StringGuard:EndsWith(".png"):IsValid()

- :Alpha([message])
  Checks if the text contains only letters (A-Z).
  Example: Guard(word).StringGuard:Alpha():IsValid()

- :Numeric([message])
  Checks if the text contains only numbers (0-9).
  Example: Guard(pin).StringGuard:Numeric():IsValid()

- :Alphanumeric([message])
  Checks if the text contains only letters and numbers.
  Example: Guard(user).StringGuard:Alphanumeric():IsValid()

- :Lowercase([message])
  Checks if all letters are lowercase.
  Example: Guard(code).StringGuard:Lowercase():IsValid()

- :Uppercase([message])
  Checks if all letters are uppercase.
  Example: Guard(flag).StringGuard:Uppercase():IsValid()


3. NUMBER GUARD (.NumberGuard)
------------------------------
Used for checking numbers.

- :Range(min, max, [message])
  Checks if the number is between min and max.
  Example: Guard(level).NumberGuard:Range(1, 99):IsValid()

- :GreaterThan(value, [message])
  Checks if the number is bigger than value.
  Example: Guard(score).NumberGuard:GreaterThan(10):IsValid()

- :LessThan(value, [message])
  Checks if the number is smaller than value.
  Example: Guard(price).NumberGuard:LessThan(50):IsValid()

- :Integer([message])
  Checks if the number has no decimals (is a whole number).
  Example: Guard(count).NumberGuard:Integer():IsValid()

- :Positive([message])
  Checks if the number is greater than 0.
  Example: Guard(money).NumberGuard:Positive():IsValid()

- :Negative([message])
  Checks if the number is less than 0.
  Example: Guard(temp).NumberGuard:Negative():IsValid()

- :NonNegative([message])
  Checks if the number is 0 or higher.
  Example: Guard(attempts).NumberGuard:NonNegative():IsValid()

- :Even([message])
  Checks if the number is an even number.
  Example: Guard(x).NumberGuard:Even():IsValid()

- :Odd([message])
  Checks if the number is an odd number.
  Example: Guard(x).NumberGuard:Odd():IsValid()

- :MultipleOf(n, [message])
  Checks if the number can be cleanly divided by n.
  Example: Guard(points).NumberGuard:MultipleOf(5):IsValid()

- :Finite([message])
  Checks if the number is a normal real number (not infinity or NaN).
  Example: Guard(val).NumberGuard:Finite():IsValid()


4. BOOLEAN GUARD (.BooleanGuard)
--------------------------------
Used for checking true/false values.

- :True([message])
  Checks if the value is strictly true.
  Example: Guard(isReady).BooleanGuard:True():IsValid()

- :False([message])
  Checks if the value is strictly false.
  Example: Guard(isDead).BooleanGuard:False():IsValid()


5. INSTANCE GUARD (.InstanceGuard)
----------------------------------
Used for checking Roblox workspace objects (Parts, Players, Models, etc.).

- :IsA(className, [message])
  Checks if the object is a specific Roblox class type.
  Example: Guard(item).InstanceGuard:IsA("Tool"):IsValid()

- :Has(childName, [expected], [message])
  Checks if the instance has a child inside it. You can optionally check what kind of child it is.
  Example: Guard(character).InstanceGuard:Has("Humanoid"):IsValid()

- :Child(childName, [recursive], [message])
  Picks a child object inside the instance and switches the guard's focus to that child!
  Example: local handle = Guard(sword).InstanceGuard:Child("Handle").Value

- :Parent(expectedInstance, [recursive], [message])
  Checks who the parent object is.
  Example: Guard(part).InstanceGuard:Parent(workspace):IsValid()

- :Attribute(attributeName, [expected], [message])
  Checks if an attribute exists on the instance.
  Example: Guard(model).InstanceGuard:Attribute("Health", 100):IsValid()

- :Named(name, [message])
  Checks if the instance's Name property matches.
  Example: Guard(part).InstanceGuard:Named("SpawnLocation"):IsValid()

- :Tag(tagName, [message])
  Checks if the instance has a CollectionService tag.
  Example: Guard(enemy).InstanceGuard:Tag("Monster"):IsValid()


6. TABLE GUARD (.TableGuard)
----------------------------
Used for checking tables (dictionaries and arrays).

- :Has(keyName, [expected], [message])
  Checks if a table has a specific key inside it.
  Example: Guard(data).TableGuard:Has("Username"):IsValid()

- :Length(min, max, [message])
  Counts all keys in the table and checks the size.
  Example: Guard(inventory).TableGuard:Length(1, 10):IsValid()

- :MinLength(min, [message])
  Checks if the table has at least a certain number of entries.
  Example: Guard(settings).TableGuard:MinLength(1):IsValid()

- :MaxLength(max, [message])
  Checks if the table has no more than a certain number of entries.
  Example: Guard(list).TableGuard:MaxLength(5):IsValid()

- :Empty([message])
  Checks if the table has zero items.
  Example: Guard(cache).TableGuard:Empty():IsValid()

- :NotEmpty([message])
  Checks if the table has at least one item.
  Example: Guard(teamList).TableGuard:NotEmpty():IsValid()

- :IsArray([message])
  Checks if the table is a normal numbered list (not a dictionary).
  Example: Guard(items).TableGuard:IsArray():IsValid()

- :Each(validatorFn, [message])
  Loops through every item in the table to make sure they all pass your rule function.
  Example: Guard(prices).TableGuard:Each(function(v) return v > 0 end):IsValid()

- :Frozen([message])
  Checks if the table is locked using table.freeze().
  Example: Guard(config).TableGuard:Frozen():IsValid()


7. FUNCTION GUARD (.FunctionGuard)
----------------------------------
Used for checking Lua functions.

- :Callable([message])
  Checks if the value is actually a function you can call.
  Example: Guard(callback).FunctionGuard:Callable():IsValid()

- :Arity(expectedCount, [message])
  Checks how many parameters the function is set up to take.
  Example: Guard(myFunc).FunctionGuard:Arity(2):IsValid()
