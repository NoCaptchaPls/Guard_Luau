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

# COMPLETE API REFERENCE
========================

This section explains every guard type and every function available in the Guard API.

> **Note:** All examples below use Markdown code fences so they remain properly formatted when this README is viewed on GitHub, in a documentation viewer, or as Markdown-compatible text.

---

# 1. BASE FUNCTIONS
===================

Base functions work on any `Guard` and can be used before selecting a specific guard type.

---

## `:Exists([message])`

Checks if the value is not `nil`.

### Example

```lua
Guard(player):Exists():Assert()
```

---

## `:Equals(expected, [message])`

Checks if the value is equal to the expected value.

### Example

```lua
Guard(status):Equals("Active"):IsValid()
```

---

## `:NotEquals(expected, [message])`

Checks if the value is **not** equal to the expected value.

### Example

```lua
Guard(role):NotEquals("Banned"):IsValid()
```

---

## `:OneOf(list, [message])`

Checks if the value matches one of the items inside a list table.

### Example

```lua
Guard(team):OneOf({"Red", "Blue"}):IsValid()
```

---

## `:Optional()`

If the value is `nil`, this skips all checks that come after it instead of failing.

### Example

```lua
Guard(nickname)
    :Optional()
    .StringGuard
    :MinLength(3)
    :IsValid()
```

---

## `:Default(fallback)`

If the value is `nil`, this replaces it with a backup value and continues checking.

### Example

```lua
Guard(score)
    :Default(0)
    .NumberGuard
    :NonNegative()
    :Unwrap()
```

---

## `:Custom(predicateFn, [message])`

Runs a custom validation function.

The function should return `true` when the value is valid.

### Example

```lua
Guard(num)
    :Custom(function(v)
        return v % 5 == 0
    end)
    :IsValid()
```

---

## `:Transform(transformerFn)`

Changes the current value using a transformation function.

The transformed value becomes the value used by subsequent operations.

### Example

```lua
Guard(text)
    :Transform(function(v)
        return v:lower()
    end)
    :Unwrap()
```

---

## `:Type(expectedType, [message])`

Checks the basic Lua type using `type()`.

### Example

```lua
Guard(x)
    :Type("string")
    :IsValid()
```

---

## `:TypeOf(expectedType, [message])`

Checks the Roblox type using `typeof()`.

This can be used for Roblox-specific types such as `"Instance"`, `"Vector3"`, `"CFrame"`, and others.

### Example

```lua
Guard(part)
    :TypeOf("Instance")
    :IsValid()
```

---

## `:IsValid()`

Finalizer.

Returns `true` if all validation checks passed.

Returns `false` if any validation check failed.

### Example

```lua
local ok = Guard(x)
    :Exists()
    :IsValid()
```

---

## `:IsInvalid()`

Finalizer.

Returns `true` if any validation check failed.

Returns `false` if all checks passed.

### Example

```lua
local bad = Guard(x)
    :Exists()
    :IsInvalid()
```

---

## `:Error()`

Returns the first validation error message.

### Example

```lua
local err = Guard(x)
    :Exists()
    :Error()
```

---

## `:GetErrors()`

Returns a list containing all validation error messages.

### Example

```lua
local errors = Guard(x)
    :Exists()
    :GetErrors()
```

---

## `:Assert([message])`

Finalizer.

Throws a script error immediately if validation fails.

If validation succeeds, execution continues normally.

### Example

```lua
Guard(health)
    .NumberGuard
    :NonNegative()
    :Assert("Health cannot be negative!")
```

---

## `:Unwrap()`

Finalizer.

Returns the final validated value if validation succeeds.

Throws an error if validation fails.

### Example

```lua
local safeValue = Guard(input)
    :Exists()
    :Unwrap()
```

---

## `:UnwrapOr(fallback)`

Finalizer.

Returns the final value if validation succeeds.

Returns the supplied fallback value if validation fails.

### Example

```lua
local final = Guard(input)
    .StringGuard
    :MinLength(3)
    :UnwrapOr("Guest")
```

---

# 2. STRING GUARD
================

Accessed using:

```lua
Guard(value).StringGuard
```

Used for validating strings and text.

---

## `:Length(min, max, [message])`

Checks if the string length is between `min` and `max`.

### Example

```lua
Guard(name)
    .StringGuard
    :Length(3, 10)
    :IsValid()
```

---

## `:MinLength(min, [message])`

Checks if the string has at least `min` characters.

### Example

```lua
Guard(name)
    .StringGuard
    :MinLength(3)
    :IsValid()
```

---

## `:MaxLength(max, [message])`

Checks if the string has no more than `max` characters.

### Example

```lua
Guard(bio)
    .StringGuard
    :MaxLength(100)
    :IsValid()
```

---

## `:Empty([message])`

Checks if the string is completely empty.

```lua
Guard(input)
    .StringGuard
    :Empty()
    :IsValid()
```

---

## `:NotEmpty([message])`

Checks if the string is not empty.

### Example

```lua
Guard(input)
    .StringGuard
    :NotEmpty()
    :IsValid()
```

---

## `:Pattern(luaPattern, [message])`

Checks if the string matches a Lua pattern.

### Example

```lua
Guard(email)
    .StringGuard
    :Pattern("^[%w]+@[%w]+%.[%w]+$")
    :IsValid()
```

---

## `:Contains(substring, [message])`

Checks if the string contains the specified substring.

### Example

```lua
Guard(chat)
    .StringGuard
    :Contains("hello")
    :IsValid()
```

---

## `:StartsWith(prefix, [message])`

Checks if the string starts with the specified prefix.

### Example

```lua
Guard(command)
    .StringGuard
    :StartsWith("!")
    :IsValid()
```

---

## `:EndsWith(suffix, [message])`

Checks if the string ends with the specified suffix.

### Example

```lua
Guard(filename)
    .StringGuard
    :EndsWith(".png")
    :IsValid()
```

---

## `:Alpha([message])`

Checks if the string contains only alphabetic characters.

### Example

```lua
Guard(word)
    .StringGuard
    :Alpha()
    :IsValid()
```

---

## `:Numeric([message])`

Checks if the string contains only numeric characters (`0-9`).

### Example

```lua
Guard(pin)
    .StringGuard
    :Numeric()
    :IsValid()
```

---

## `:Alphanumeric([message])`

Checks if the string contains only letters and numbers.

### Example

```lua
Guard(username)
    .StringGuard
    :Alphanumeric()
    :IsValid()
```

---

## `:Lowercase([message])`

Checks if all letters in the string are lowercase.

### Example

```lua
Guard(code)
    .StringGuard
    :Lowercase()
    :IsValid()
```

---

## `:Uppercase([message])`

Checks if all letters in the string are uppercase.

### Example

```lua
Guard(flag)
    .StringGuard
    :Uppercase()
    :IsValid()
```

---

# 3. NUMBER GUARD
================

Accessed using:

```lua
Guard(value).NumberGuard
```

Used for validating numbers.

---

## `:Range(min, max, [message])`

Checks if the number is between `min` and `max`.

### Example

```lua
Guard(level)
    .NumberGuard
    :Range(1, 99)
    :IsValid()
```

---

## `:GreaterThan(value, [message])`

Checks if the number is greater than the specified value.

### Example

```lua
Guard(score)
    .NumberGuard
    :GreaterThan(10)
    :IsValid()
```

---

## `:LessThan(value, [message])`

Checks if the number is less than the specified value.

### Example

```lua
Guard(price)
    .NumberGuard
    :LessThan(50)
    :IsValid()
```

---

## `:Integer([message])`

Checks if the number is a whole number with no decimal component.

### Example

```lua
Guard(count)
    .NumberGuard
    :Integer()
    :IsValid()
```

---

## `:Positive([message])`

Checks if the number is greater than `0`.

### Example

```lua
Guard(money)
    .NumberGuard
    :Positive()
    :IsValid()
```

---

## `:Negative([message])`

Checks if the number is less than `0`.

### Example

```lua
Guard(temp)
    .NumberGuard
    :Negative()
    :IsValid()
```

---

## `:NonNegative([message])`

Checks if the number is greater than or equal to `0`.

### Example

```lua
Guard(attempts)
    .NumberGuard
    :NonNegative()
    :IsValid()
```

---

## `:Even([message])`

Checks if the number is even.

### Example

```lua
Guard(x)
    .NumberGuard
    :Even()
    :IsValid()
```

---

## `:Odd([message])`

Checks if the number is odd.

### Example

```lua
Guard(x)
    .NumberGuard
    :Odd()
    :IsValid()
```

---

## `:MultipleOf(n, [message])`

Checks if the number is evenly divisible by `n`.

### Example

```lua
Guard(points)
    .NumberGuard
    :MultipleOf(5)
    :IsValid()
```

---

## `:Finite([message])`

Checks that the number is finite and is not infinity or `NaN`.

### Example

```lua
Guard(value)
    .NumberGuard
    :Finite()
    :IsValid()
```

---

# 4. BOOLEAN GUARD
=================

Accessed using:

```lua
Guard(value).BooleanGuard
```

Used for validating boolean values.

---

## `:True([message])`

Checks if the value is strictly `true`.

### Example

```lua
Guard(isReady)
    .BooleanGuard
    :True()
    :IsValid()
```

---

## `:False([message])`

Checks if the value is strictly `false`.

### Example

```lua
Guard(isDead)
    .BooleanGuard
    :False()
    :IsValid()
```

---

# 5. INSTANCE GUARD
===================

Accessed using:

```lua
Guard(value).InstanceGuard
```

Used for validating Roblox `Instance` objects such as Parts, Players, Models, Tools, Folders, and other Roblox objects.

---

## `:IsA(className, [message])`

Checks if the object belongs to the specified Roblox class.

### Example

```lua
Guard(item)
    .InstanceGuard
    :IsA("Tool")
    :IsValid()
```

---

## `:Has(childName, [expected], [message])`

Checks if the instance contains a child with the specified name.

The optional `expected` argument can be used to validate the expected value or type of the child.

### Example

```lua
Guard(character)
    .InstanceGuard
    :Has("Humanoid")
    :IsValid()
```

---

## `:Child(childName, [recursive], [message])`

Finds a child inside the instance and switches the guard's focus to that child.

### Example

```lua
local handle = Guard(sword)
    .InstanceGuard
    :Child("Handle")
    .Value
```

---

## `:Parent(expectedInstance, [recursive], [message])`

Checks whether the instance has the expected parent.

### Example

```lua
Guard(part)
    .InstanceGuard
    :Parent(workspace)
    :IsValid()
```

---

## `:Attribute(attributeName, [expected], [message])`

Checks whether the instance contains the specified attribute.

The optional `expected` argument can be used to check the attribute's value.

### Example

```lua
Guard(model)
    .InstanceGuard
    :Attribute("Health", 100)
    :IsValid()
```

---

## `:Named(name, [message])`

Checks whether the instance's `Name` property matches the supplied name.

### Example

```lua
Guard(part)
    .InstanceGuard
    :Named("SpawnLocation")
    :IsValid()
```

---

## `:Tag(tagName, [message])`

Checks whether the instance has the specified CollectionService tag.

### Example

```lua
Guard(enemy)
    .InstanceGuard
    :Tag("Monster")
    :IsValid()
```

---

# 6. TABLE GUARD
===============

Accessed using:

```lua
Guard(value).TableGuard
```

Used for validating Lua tables, including arrays and dictionaries.

---

## `:Has(keyName, [expected], [message])`

Checks whether the table contains the specified key.

### Example

```lua
Guard(data)
    .TableGuard
    :Has("Username")
    :IsValid()
```

---

## `:Length(min, max, [message])`

Counts the entries in the table and checks whether the count is between `min` and `max`.

### Example

```lua
Guard(inventory)
    .TableGuard
    :Length(1, 10)
    :IsValid()
```

---

## `:MinLength(min, [message])`

Checks whether the table contains at least `min` entries.

### Example

```lua
Guard(settings)
    .TableGuard
    :MinLength(1)
    :IsValid()
```

---

## `:MaxLength(max, [message])`

Checks whether the table contains no more than `max` entries.

### Example

```lua
Guard(list)
    .TableGuard
    :MaxLength(5)
    :IsValid()
```

---

## `:Empty([message])`

Checks whether the table contains zero entries.

### Example

```lua
Guard(cache)
    .TableGuard
    :Empty()
    :IsValid()
```

---

## `:NotEmpty([message])`

Checks whether the table contains at least one entry.

### Example

```lua
Guard(teamList)
    .TableGuard
    :NotEmpty()
    :IsValid()
```

---

## `:IsArray([message])`

Checks whether the table is a normal numbered array rather than a dictionary.

### Example

```lua
Guard(items)
    .TableGuard
    :IsArray()
    :IsValid()
```

---

## `:Each(validatorFn, [message])`

Runs a custom validation function against every item in the table.

Every item must pass the validator function.

### Example

```lua
Guard(prices)
    .TableGuard
    :Each(function(v)
        return v > 0
    end)
    :IsValid()
```

---

## `:Frozen([message])`

Checks whether the table has been frozen using `table.freeze()`.

### Example

```lua
Guard(config)
    .TableGuard
    :Frozen()
    :IsValid()
```

---

# 7. FUNCTION GUARD
==================

Accessed using:

```lua
Guard(value).FunctionGuard
```

Used for validating Lua functions.

---

## `:Callable([message])`

Checks whether the value is a callable function.

### Example

```lua
Guard(callback)
    .FunctionGuard
    :Callable()
    :IsValid()
```

---

## `:Arity(expectedCount, [message])`

Checks how many parameters the function is configured to accept.

### Example

```lua
Guard(myFunc)
    .FunctionGuard
    :Arity(2)
    :IsValid()
```

---

# QUICK REFERENCE
=================

| Guard Type | Accessor | Purpose |
|---|---|---|
| Base | `Guard(value)` | General-purpose validation |
| String | `.StringGuard` | Validate strings |
| Number | `.NumberGuard` | Validate numbers |
| Boolean | `.BooleanGuard` | Validate booleans |
| Instance | `.InstanceGuard` | Validate Roblox Instances |
| Table | `.TableGuard` | Validate tables |
| Function | `.FunctionGuard` | Validate functions |

---

# COMMON VALIDATION PATTERNS
============================

## Basic Validation

A simple validation chain can look like this:

```lua
local valid = Guard(username)
    :Exists()
    .StringGuard
    :NotEmpty()
    :IsValid()
```

---

## Multiple Checks

Multiple checks can be chained together.

```lua
local valid = Guard(username)
    :Exists()
    .StringGuard
    :NotEmpty()
    :MinLength(3)
    :MaxLength(20)
    :Alphanumeric()
    :IsValid()
```

---

## Getting the Validated Value

Use `:Unwrap()` when you want to retrieve the value after validation.

```lua
local username = Guard(input)
    :Exists()
    .StringGuard
    :NotEmpty()
    :Unwrap()
```

If validation fails, `:Unwrap()` throws an error.

---

## Using a Fallback

Use `:UnwrapOr()` when you want a fallback value instead of an error.

```lua
local username = Guard(input)
    :Exists()
    .StringGuard
    :NotEmpty()
    :UnwrapOr("Guest")
```

---

## Collecting Errors

Use `:Error()` to retrieve the first validation error.

```lua
local errorMessage = Guard(input)
    :Exists()
    .StringGuard
    :MinLength(3)
    :Error()
```

Use `:GetErrors()` to retrieve all validation errors.

```lua
local errors = Guard(input)
    :Exists()
    .StringGuard
    :MinLength(3)
    :MaxLength(20)
    :GetErrors()
```

---

## Throwing on Validation Failure

Use `:Assert()` when validation failure should immediately throw an error.

```lua
Guard(health)
    :Exists()
    .NumberGuard
    :NonNegative()
    :Assert("Health must be zero or greater.")
```

---

# COMPLETE EXAMPLE
==================

The following example demonstrates how several guard features can be combined:

```lua
local function validatePlayerData(data)
    return Guard(data)
        :Exists()
        .TableGuard
        :NotEmpty()
        :Has("Username")
        :Has("Level")
        :IsValid()
end

local playerData = {
    Username = "Zachy",
    Level = 25,
}

if validatePlayerData(playerData) then
    print("Player data is valid!")
else
    print("Player data is invalid!")
end
```

---

# API SUMMARY
=============

## Base

```text
Exists
Equals
NotEquals
OneOf
Optional
Default
Custom
Transform
Type
TypeOf
IsValid
IsInvalid
Error
GetErrors
Assert
Unwrap
UnwrapOr
```

## StringGuard

```text
Length
MinLength
MaxLength
Empty
NotEmpty
Pattern
Contains
StartsWith
EndsWith
Alpha
Numeric
Alphanumeric
Lowercase
Uppercase
```

## NumberGuard

```text
Range
GreaterThan
LessThan
Integer
Positive
Negative
NonNegative
Even
Odd
MultipleOf
Finite
```

## BooleanGuard

```text
True
False
```

## InstanceGuard

```text
IsA
Has
Child
Parent
Attribute
Named
Tag
```

## TableGuard

```text
Has
Length
MinLength
MaxLength
Empty
NotEmpty
IsArray
Each
Frozen
```

## FunctionGuard

```text
Callable
Arity
```

---

# END OF API REFERENCE
======================
