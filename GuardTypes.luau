--!strict

--[[
	Guard
	
	UNDER MIT LICENSE - COPYRIGHT (C) 2026 TALHA a.k.a @ZACHY
	=====
	A fluent, chainable validation library for Luau.

		local Guard = require(path.to.Guard)

		local ok = Guard(player.Name)
			.StringGuard:Length(3, 20)
			:Alphanumeric()
			:IsValid()


	You can now also chain base methods straight off the wrapper without
	picking a namespace first, e.g. `Guard(x):Exists():Custom(fn):Assert()`
	- only reach for `.StringGuard` / `.NumberGuard` / etc. when you need a
	type-specific check.
]]

local CollectionService = game:GetService("CollectionService")

export type StringGuard = {
	Value: string,
	Valid: boolean,
	_errors: {string},

	-- base
	Exists: (self: StringGuard, message: string?) -> StringGuard,
	Equals: (self: StringGuard, expected: any, message: string?) -> StringGuard,
	NotEquals: (self: StringGuard, expected: any, message: string?) -> StringGuard,
	OneOf: (self: StringGuard, list: {string}, message: string?) -> StringGuard,
	Optional: (self: StringGuard) -> StringGuard,
	Default: (self: StringGuard, fallback: string) -> StringGuard,
	Custom: (self: StringGuard, predicate: (value: string) -> boolean, message: string?) -> StringGuard,
	Transform: (self: StringGuard, transformer: (value: string) -> string) -> StringGuard,
	Type: (self: StringGuard, expected: string, message: string?) -> StringGuard,
	TypeOf: (self: StringGuard, expected: string, message: string?) -> StringGuard,
	IsValid: (self: StringGuard) -> boolean,
	IsInvalid: (self: StringGuard) -> boolean,
	Error: (self: StringGuard) -> string?,
	GetErrors: (self: StringGuard) -> {string},
	Assert: (self: StringGuard, message: string?) -> StringGuard,
	Unwrap: (self: StringGuard) -> string,
	UnwrapOr: (self: StringGuard, fallback: string) -> string,

	-- string-specific
	Length: (self: StringGuard, minimum: number, maximum: number?, message: string?) -> StringGuard,
	MinLength: (self: StringGuard, minimum: number, message: string?) -> StringGuard,
	MaxLength: (self: StringGuard, maximum: number, message: string?) -> StringGuard,
	Empty: (self: StringGuard, message: string?) -> StringGuard,
	NotEmpty: (self: StringGuard, message: string?) -> StringGuard,
	Pattern: (self: StringGuard, pattern: string, message: string?) -> StringGuard,
	Contains: (self: StringGuard, substring: string, message: string?) -> StringGuard,
	StartsWith: (self: StringGuard, prefix: string, message: string?) -> StringGuard,
	EndsWith: (self: StringGuard, suffix: string, message: string?) -> StringGuard,
	Alpha: (self: StringGuard, message: string?) -> StringGuard,
	Numeric: (self: StringGuard, message: string?) -> StringGuard,
	Alphanumeric: (self: StringGuard, message: string?) -> StringGuard,
	Lowercase: (self: StringGuard, message: string?) -> StringGuard,
	Uppercase: (self: StringGuard, message: string?) -> StringGuard,
}

export type NumberGuard = {
	Value: number,
	Valid: boolean,
	_errors: {string},

	-- base
	Exists: (self: NumberGuard, message: string?) -> NumberGuard,
	Equals: (self: NumberGuard, expected: any, message: string?) -> NumberGuard,
	NotEquals: (self: NumberGuard, expected: any, message: string?) -> NumberGuard,
	OneOf: (self: NumberGuard, list: {number}, message: string?) -> NumberGuard,
	Optional: (self: NumberGuard) -> NumberGuard,
	Default: (self: NumberGuard, fallback: number) -> NumberGuard,
	Custom: (self: NumberGuard, predicate: (value: number) -> boolean, message: string?) -> NumberGuard,
	Transform: (self: NumberGuard, transformer: (value: number) -> number) -> NumberGuard,
	Type: (self: NumberGuard, expected: string, message: string?) -> NumberGuard,
	TypeOf: (self: NumberGuard, expected: string, message: string?) -> NumberGuard,
	IsValid: (self: NumberGuard) -> boolean,
	IsInvalid: (self: NumberGuard) -> boolean,
	Error: (self: NumberGuard) -> string?,
	GetErrors: (self: NumberGuard) -> {string},
	Assert: (self: NumberGuard, message: string?) -> NumberGuard,
	Unwrap: (self: NumberGuard) -> number,
	UnwrapOr: (self: NumberGuard, fallback: number) -> number,

	-- number-specific
	Range: (self: NumberGuard, minimum: number, maximum: number, message: string?) -> NumberGuard,
	GreaterThan: (self: NumberGuard, value: number, message: string?) -> NumberGuard,
	LessThan: (self: NumberGuard, value: number, message: string?) -> NumberGuard,
	Integer: (self: NumberGuard, message: string?) -> NumberGuard,
	Positive: (self: NumberGuard, message: string?) -> NumberGuard,
	Negative: (self: NumberGuard, message: string?) -> NumberGuard,
	NonNegative: (self: NumberGuard, message: string?) -> NumberGuard,
	Even: (self: NumberGuard, message: string?) -> NumberGuard,
	Odd: (self: NumberGuard, message: string?) -> NumberGuard,
	MultipleOf: (self: NumberGuard, n: number, message: string?) -> NumberGuard,
	Finite: (self: NumberGuard, message: string?) -> NumberGuard,
}

export type BooleanGuard = {
	Value: boolean,
	Valid: boolean,
	_errors: {string},

	-- base
	Exists: (self: BooleanGuard, message: string?) -> BooleanGuard,
	Equals: (self: BooleanGuard, expected: any, message: string?) -> BooleanGuard,
	NotEquals: (self: BooleanGuard, expected: any, message: string?) -> BooleanGuard,
	OneOf: (self: BooleanGuard, list: {boolean}, message: string?) -> BooleanGuard,
	Optional: (self: BooleanGuard) -> BooleanGuard,
	Default: (self: BooleanGuard, fallback: boolean) -> BooleanGuard,
	Custom: (self: BooleanGuard, predicate: (value: boolean) -> boolean, message: string?) -> BooleanGuard,
	Transform: (self: BooleanGuard, transformer: (value: boolean) -> boolean) -> BooleanGuard,
	Type: (self: BooleanGuard, expected: string, message: string?) -> BooleanGuard,
	TypeOf: (self: BooleanGuard, expected: string, message: string?) -> BooleanGuard,
	IsValid: (self: BooleanGuard) -> boolean,
	IsInvalid: (self: BooleanGuard) -> boolean,
	Error: (self: BooleanGuard) -> string?,
	GetErrors: (self: BooleanGuard) -> {string},
	Assert: (self: BooleanGuard, message: string?) -> BooleanGuard,
	Unwrap: (self: BooleanGuard) -> boolean,
	UnwrapOr: (self: BooleanGuard, fallback: boolean) -> boolean,

	-- boolean-specific
	True: (self: BooleanGuard, message: string?) -> BooleanGuard,
	False: (self: BooleanGuard, message: string?) -> BooleanGuard,
}

export type InstanceGuard<T> = {
	Value: T,
	Valid: boolean,
	_errors: {string},

	-- base
	Exists: (self: InstanceGuard<T>, message: string?) -> InstanceGuard<T>,
	Equals: (self: InstanceGuard<T>, expected: any, message: string?) -> InstanceGuard<T>,
	NotEquals: (self: InstanceGuard<T>, expected: any, message: string?) -> InstanceGuard<T>,
	OneOf: (self: InstanceGuard<T>, list: {any}, message: string?) -> InstanceGuard<T>,
	Optional: (self: InstanceGuard<T>) -> InstanceGuard<T>,
	Default: (self: InstanceGuard<T>, fallback: T) -> InstanceGuard<T>,
	Custom: (self: InstanceGuard<T>, predicate: (value: T) -> boolean, message: string?) -> InstanceGuard<T>,
	Transform: (self: InstanceGuard<T>, transformer: (value: T) -> T) -> InstanceGuard<T>,
	Type: (self: InstanceGuard<T>, expected: string, message: string?) -> InstanceGuard<T>,
	TypeOf: (self: InstanceGuard<T>, expected: string, message: string?) -> InstanceGuard<T>,
	IsValid: (self: InstanceGuard<T>) -> boolean,
	IsInvalid: (self: InstanceGuard<T>) -> boolean,
	Error: (self: InstanceGuard<T>) -> string?,
	GetErrors: (self: InstanceGuard<T>) -> {string},
	Assert: (self: InstanceGuard<T>, message: string?) -> InstanceGuard<T>,
	Unwrap: (self: InstanceGuard<T>) -> T,
	UnwrapOr: (self: InstanceGuard<T>, fallback: T) -> T,

	-- instance-specific
	IsA: (self: InstanceGuard<T>, className: string, message: string?) -> InstanceGuard<T>,
	Has: (self: InstanceGuard<T>, name: string, expected: (string | Instance)?, message: string?) -> InstanceGuard<T>,
	Child: (self: InstanceGuard<T>, name: string, recursive: boolean?, message: string?) -> InstanceGuard<T>,
	Parent: (self: InstanceGuard<T>, expected: Instance, recursive: boolean?, message: string?) -> InstanceGuard<T>,
	Attribute: (self: InstanceGuard<T>, name: string, expected: any?, message: string?) -> InstanceGuard<T>,
	Named: (self: InstanceGuard<T>, name: string, message: string?) -> InstanceGuard<T>,
	Tag: (self: InstanceGuard<T>, tag: string, message: string?) -> InstanceGuard<T>,
}

export type TableGuard<T> = {
	Value: T,
	Valid: boolean,
	_errors: {string},

	-- base
	Exists: (self: TableGuard<T>, message: string?) -> TableGuard<T>,
	Equals: (self: TableGuard<T>, expected: any, message: string?) -> TableGuard<T>,
	NotEquals: (self: TableGuard<T>, expected: any, message: string?) -> TableGuard<T>,
	OneOf: (self: TableGuard<T>, list: {any}, message: string?) -> TableGuard<T>,
	Optional: (self: TableGuard<T>) -> TableGuard<T>,
	Default: (self: TableGuard<T>, fallback: T) -> TableGuard<T>,
	Custom: (self: TableGuard<T>, predicate: (value: T) -> boolean, message: string?) -> TableGuard<T>,
	Transform: (self: TableGuard<T>, transformer: (value: T) -> T) -> TableGuard<T>,
	Type: (self: TableGuard<T>, expected: string, message: string?) -> TableGuard<T>,
	TypeOf: (self: TableGuard<T>, expected: string, message: string?) -> TableGuard<T>,
	IsValid: (self: TableGuard<T>) -> boolean,
	IsInvalid: (self: TableGuard<T>) -> boolean,
	Error: (self: TableGuard<T>) -> string?,
	GetErrors: (self: TableGuard<T>) -> {string},
	Assert: (self: TableGuard<T>, message: string?) -> TableGuard<T>,
	Unwrap: (self: TableGuard<T>) -> T,
	UnwrapOr: (self: TableGuard<T>, fallback: T) -> T,

	-- table-specific
	Has: (self: TableGuard<T>, name: string, expected: any?, message: string?) -> TableGuard<T>,
	Length: (self: TableGuard<T>, minimum: number, maximum: number?, message: string?) -> TableGuard<T>,
	MinLength: (self: TableGuard<T>, minimum: number, message: string?) -> TableGuard<T>,
	MaxLength: (self: TableGuard<T>, maximum: number, message: string?) -> TableGuard<T>,
	Empty: (self: TableGuard<T>, message: string?) -> TableGuard<T>,
	NotEmpty: (self: TableGuard<T>, message: string?) -> TableGuard<T>,
	IsArray: (self: TableGuard<T>, message: string?) -> TableGuard<T>,
	Each: (self: TableGuard<T>, validator: (value: any, key: any) -> boolean, message: string?) -> TableGuard<T>,
	Frozen: (self: TableGuard<T>, message: string?) -> TableGuard<T>,
}

export type FunctionGuard<T> = {
	Value: T,
	Valid: boolean,
	_errors: {string},

	Exists: (self: FunctionGuard<T>, message: string?) -> FunctionGuard<T>,
	Equals: (self: FunctionGuard<T>, expected: any, message: string?) -> FunctionGuard<T>,
	NotEquals: (self: FunctionGuard<T>, expected: any, message: string?) -> FunctionGuard<T>,
	OneOf: (self: FunctionGuard<T>, list: {any}, message: string?) -> FunctionGuard<T>,
	Optional: (self: FunctionGuard<T>) -> FunctionGuard<T>,
	Default: (self: FunctionGuard<T>, fallback: T) -> FunctionGuard<T>,
	Custom: (self: FunctionGuard<T>, predicate: (value: T) -> boolean, message: string?) -> FunctionGuard<T>,
	Transform: (self: FunctionGuard<T>, transformer: (value: T) -> T) -> FunctionGuard<T>,
	Type: (self: FunctionGuard<T>, expected: string, message: string?) -> FunctionGuard<T>,
	TypeOf: (self: FunctionGuard<T>, expected: string, message: string?) -> FunctionGuard<T>,
	IsValid: (self: FunctionGuard<T>) -> boolean,
	IsInvalid: (self: FunctionGuard<T>) -> boolean,
	Error: (self: FunctionGuard<T>) -> string?,
	GetErrors: (self: FunctionGuard<T>) -> {string},
	Assert: (self: FunctionGuard<T>, message: string?) -> FunctionGuard<T>,
	Unwrap: (self: FunctionGuard<T>) -> T,
	UnwrapOr: (self: FunctionGuard<T>, fallback: T) -> T,

	Callable: (self: FunctionGuard<T>, message: string?) -> FunctionGuard<T>,

	Arity: (self: FunctionGuard<T>, expected: number, message: string?) -> FunctionGuard<T>,
}

export type GuardWrapper = {
	Value: any,
	Valid: boolean,
	_errors: {string},
	
	StringGuard: StringGuard,
	NumberGuard: NumberGuard,
	BooleanGuard: BooleanGuard,
	InstanceGuard: InstanceGuard<Instance>,
	TableGuard: TableGuard<{[any]: any}>,
	FunctionGuard: FunctionGuard<(...any) -> ...any>,

	Exists: (self: GuardWrapper, message: string?) -> GuardWrapper,
	Equals: (self: GuardWrapper, expected: any, message: string?) -> GuardWrapper,
	NotEquals: (self: GuardWrapper, expected: any, message: string?) -> GuardWrapper,
	OneOf: (self: GuardWrapper, list: {any}, message: string?) -> GuardWrapper,
	Optional: (self: GuardWrapper) -> GuardWrapper,
	Default: (self: GuardWrapper, fallback: any) -> GuardWrapper,
	Custom: (self: GuardWrapper, predicate: (value: any) -> boolean, message: string?) -> GuardWrapper,
	Transform: (self: GuardWrapper, transformer: (value: any) -> any) -> GuardWrapper,
	Type: (self: GuardWrapper, expected: string, message: string?) -> GuardWrapper,
	TypeOf: (self: GuardWrapper, expected: string, message: string?) -> GuardWrapper,
	IsValid: (self: GuardWrapper) -> boolean,
	IsInvalid: (self: GuardWrapper) -> boolean,
	Error: (self: GuardWrapper) -> string?,
	GetErrors: (self: GuardWrapper) -> {string},
	Assert: (self: GuardWrapper, message: string?) -> GuardWrapper,
	Unwrap: (self: GuardWrapper) -> any,
	UnwrapOr: (self: GuardWrapper, fallback: any) -> any,
}



local Methods = {}

local function notReady(self: any): boolean
	return (not self.Valid) or self._skipped == true
end

local function fail(self: any, message: string)
	if self.Valid and not self._skipped then
		self.Valid = false
		table.insert(self._errors, message)
	end
	return self
end

local function check(self: any, condition: boolean, message: string)
	if notReady(self) then return self end
	if not condition then return fail(self, message) end
	return self
end

local function getLength(value: any): number
	if type(value) == "string" then
		return #(value :: string)
	elseif type(value) == "table" then
		local count = 0
		for _ in pairs(value :: {[any]: any}) do
			count += 1
		end
		return count
	end
	return -1
end

function Methods:Exists(message: string?)
	return check(self, self.Value ~= nil, message or "Value does not exist")
end

function Methods:Equals(expected: any, message: string?)
	return check(self, self.Value == expected, message or "Values are not equal")
end

function Methods:NotEquals(expected: any, message: string?)
	return check(self, self.Value ~= expected, message or "Values are equal")
end

function Methods:OneOf(list: {any}, message: string?)
	if notReady(self) then return self end
	for _, v in ipairs(list) do
		if v == self.Value then return self end
	end
	return fail(self, message or "Value is not one of the allowed values")
end

function Methods:Optional()
	if self.Value == nil then
		self._skipped = true
	end
	return self
end

function Methods:Default(fallback: any)
	if self.Value == nil then
		self.Value = fallback
		self._skipped = false
	end
	return self
end

function Methods:Custom(predicate: (value: any) -> boolean, message: string?)
	if notReady(self) then return self end
	local ok, result = pcall(predicate, self.Value)
	if not ok then
		return fail(self, message or ("Custom check errored: " .. tostring(result)))
	end
	return check(self, result == true, message or "Custom check failed")
end

function Methods:Transform(transformer: (value: any) -> any)
	if notReady(self) then return self end
	local ok, result = pcall(transformer, self.Value)
	if not ok then
		return fail(self, "Transform errored: " .. tostring(result))
	end
	self.Value = result
	return self
end

function Methods:Type(expected: string, message: string?)
	return check(self, type(self.Value) == expected, message or ("Expected type \"" .. expected .. "\""))
end

function Methods:TypeOf(expected: string, message: string?)
	return check(self, typeof(self.Value) == expected, message or ("Expected typeof \"" .. expected .. "\""))
end

function Methods:IsValid()
	return self.Valid
end

function Methods:IsInvalid()
	return not self.Valid
end

function Methods:Error()
	return self._errors[1]
end

function Methods:GetErrors()
	return table.clone(self._errors)
end

function Methods:Assert(message: string?)
	if not self.Valid then
		error(message or self:Error() or "Guard assertion failed", 2)
	end
	return self
end

function Methods:Unwrap(): any
	if not self.Valid then
		error(self:Error() or "Attempted to unwrap an invalid guard", 2)
	end
	return self.Value
end

function Methods:UnwrapOr(fallback: any): any
	if not self.Valid then
		return fallback
	end
	return self.Value
end

-- ===== String methods =====

function Methods:Length(minimum: number, maximum: number?, message: string?)
	if notReady(self) then return self end
	local len = getLength(self.Value)
	if len < 0 then return fail(self, message or "Length requires a string or table") end
	local min = minimum
	local max = maximum or minimum
	return check(self, len >= min and len <= max, message or "Invalid length")
end

function Methods:MinLength(minimum: number, message: string?)
	if notReady(self) then return self end
	local len = getLength(self.Value)
	if len < 0 then return fail(self, message or "MinLength requires a string or table") end
	return check(self, len >= minimum, message or ("Length must be at least " .. minimum))
end

function Methods:MaxLength(maximum: number, message: string?)
	if notReady(self) then return self end
	local len = getLength(self.Value)
	if len < 0 then return fail(self, message or "MaxLength requires a string or table") end
	return check(self, len <= maximum, message or ("Length must be at most " .. maximum))
end

function Methods:Empty(message: string?)
	if notReady(self) then return self end
	local len = getLength(self.Value)
	if len < 0 then return fail(self, message or "Empty requires a string or table") end
	return check(self, len == 0, message or "Value is not empty")
end

function Methods:NotEmpty(message: string?)
	if notReady(self) then return self end
	local len = getLength(self.Value)
	if len < 0 then return fail(self, message or "NotEmpty requires a string or table") end
	return check(self, len > 0, message or "Value is empty")
end

function Methods:Pattern(pattern: string, message: string?)
	if notReady(self) then return self end
	if type(self.Value) ~= "string" then return fail(self, message or "Pattern requires a string") end
	return check(self, string.match(self.Value, pattern) ~= nil, message or "Value does not match pattern")
end

function Methods:Contains(substring: string, message: string?)
	if notReady(self) then return self end
	if type(self.Value) ~= "string" then return fail(self, message or "Contains requires a string") end
	return check(self, string.find(self.Value, substring, 1, true) ~= nil, message or ("Value does not contain \"" .. substring .. "\""))
end

function Methods:StartsWith(prefix: string, message: string?)
	if notReady(self) then return self end
	if type(self.Value) ~= "string" then return fail(self, message or "StartsWith requires a string") end
	return check(self, string.sub(self.Value, 1, #prefix) == prefix, message or ("Value does not start with \"" .. prefix .. "\""))
end

function Methods:EndsWith(suffix: string, message: string?)
	if notReady(self) then return self end
	if type(self.Value) ~= "string" then return fail(self, message or "EndsWith requires a string") end
	local value = self.Value :: string
	local matches = suffix == "" or string.sub(value, -#suffix) == suffix
	return check(self, matches, message or ("Value does not end with \"" .. suffix .. "\""))
end

function Methods:Alpha(message: string?)
	if notReady(self) then return self end
	if type(self.Value) ~= "string" then return fail(self, message or "Alpha requires a string") end
	return check(self, string.match(self.Value, "^%a+$") ~= nil, message or "Value must contain letters only")
end

function Methods:Numeric(message: string?)
	if notReady(self) then return self end
	if type(self.Value) ~= "string" then return fail(self, message or "Numeric requires a string") end
	return check(self, string.match(self.Value, "^%d+$") ~= nil, message or "Value must contain digits only")
end

function Methods:Alphanumeric(message: string?)
	if notReady(self) then return self end
	if type(self.Value) ~= "string" then return fail(self, message or "Alphanumeric requires a string") end
	return check(self, string.match(self.Value, "^%w+$") ~= nil, message or "Value must be alphanumeric")
end

function Methods:Lowercase(message: string?)
	if notReady(self) then return self end
	if type(self.Value) ~= "string" then return fail(self, message or "Lowercase requires a string") end
	local value = self.Value :: string
	return check(self, value == string.lower(value), message or "Value must be lowercase")
end

function Methods:Uppercase(message: string?)
	if notReady(self) then return self end
	if type(self.Value) ~= "string" then return fail(self, message or "Uppercase requires a string") end
	local value = self.Value :: string
	return check(self, value == string.upper(value), message or "Value must be uppercase")
end

-- ===== Number methods =====

function Methods:Range(minimum: number, maximum: number, message: string?)
	if not self.Valid then return self end
	if type(self.Value) ~= "number" then return fail(self, message or "Range requires a number") end
	return check(self, (self.Value :: any) >= minimum and (self.Value :: any) <= maximum, message or "Value is outside the allowed range")
end

function Methods:GreaterThan(value: number, message: string?)
	if not self.Valid then return self end
	return check(self, type(self.Value) == "number" and (self.Value :: any) > value, message or "Value is not greater than expected")
end

function Methods:LessThan(value: number, message: string?)
	if not self.Valid then return self end
	return check(self, type(self.Value) == "number" and (self.Value :: any) < value, message or "Value is not less than expected")
end

function Methods:Integer(message: string?)
	return check(self, type(self.Value) == "number" and (self.Value :: any) % 1 == 0, message or "Value is not an integer")
end

function Methods:Positive(message: string?)
	return check(self, type(self.Value) == "number" and (self.Value :: any) > 0, message or "Value is not positive")
end

function Methods:Negative(message: string?)
	return check(self, type(self.Value) == "number" and (self.Value :: any) < 0, message or "Value is not negative")
end

function Methods:NonNegative(message: string?)
	return check(self, type(self.Value) == "number" and (self.Value :: any) >= 0, message or "Value is negative")
end

function Methods:Even(message: string?)
	return check(self, type(self.Value) == "number" and (self.Value :: any) % 2 == 0, message or "Value is not even")
end

function Methods:Odd(message: string?)
	return check(self, type(self.Value) == "number" and (self.Value :: any) % 2 ~= 0, message or "Value is not odd")
end

function Methods:MultipleOf(n: number, message: string?)
	return check(self, type(self.Value) == "number" and (self.Value :: any) % n == 0, message or ("Value is not a multiple of " .. tostring(n)))
end

function Methods:Finite(message: string?)
	if type(self.Value) ~= "number" then return fail(self, message or "Finite requires a number") end
	local v = self.Value :: number
	return check(self, v == v and v ~= math.huge and v ~= -math.huge, message or "Value is not finite")
end

-- ===== Boolean methods =====

function Methods:True(message: string?)
	return check(self, self.Value == true, message or "Value is not true")
end

function Methods:False(message: string?)
	return check(self, self.Value == false, message or "Value is not false")
end

-- ===== Instance methods =====

function Methods:IsA(className: string, message: string?)
	local isValid = typeof(self.Value) == "Instance" and (self.Value :: any):IsA(className)
	return check(self, isValid, message or ("Expected " .. className))
end

function Methods:Has(name: string, expected: any?, message: string?)
	if notReady(self) then return self end
	local value = self.Value
	if typeof(value) == "Instance" then
		local inst = value :: Instance
		local child = inst:FindFirstChild(name)
		if not child then return fail(self, message or ("Missing child \"" .. name .. "\"")) end
		if expected ~= nil then
			local matches: boolean
			if type(expected) == "string" then
				matches = child:IsA(expected :: string)
			else
				matches = child == expected
			end
			if not matches then
				return fail(self, message or ("Child \"" .. name .. "\" did not match expected value"))
			end
		end
		return self
	elseif type(value) == "table" then
		local member = (value :: any)[name]
		if member == nil then return fail(self, message or ("Missing key \"" .. name .. "\"")) end
		if expected ~= nil and member ~= expected then
			return fail(self, message or ("Key \"" .. name .. "\" did not match expected value"))
		end
		return self
	end
	return fail(self, message or "Has is not supported for this value")
end

function Methods:Child(name: string, recursive: boolean?, message: string?)
	if notReady(self) then return self end
	if typeof(self.Value) ~= "Instance" then return fail(self, message or "Child requires an Instance") end
	local child = (self.Value :: Instance):FindFirstChild(name, recursive == true)
	if not child then return fail(self, message or ("Missing child \"" .. name .. "\"")) end
	self.Value = child
	return self
end

function Methods:Parent(expected: Instance, recursive: boolean?, message: string?)
	if notReady(self) then return self end
	local inst = self.Value :: Instance
	local valid: boolean
	if recursive then
		valid = inst:IsDescendantOf(expected)
	else
		valid = inst.Parent == expected
	end
	return check(self, valid, message or "Invalid parent")
end

function Methods:Attribute(name: string, expected: any?, message: string?)
	if notReady(self) then return self end
	local attr = (self.Value :: Instance):GetAttribute(name)
	if attr == nil then return fail(self, message or ("Missing attribute \"" .. name .. "\"")) end
	if expected ~= nil then
		return check(self, attr == expected, message or ("Invalid attribute \"" .. name .. "\""))
	end
	return self
end

function Methods:Named(name: string, message: string?)
	if notReady(self) then return self end
	if typeof(self.Value) ~= "Instance" then return fail(self, message or "Named requires an Instance") end
	return check(self, (self.Value :: Instance).Name == name, message or ("Expected Instance named \"" .. name .. "\""))
end

function Methods:Tag(tag: string, message: string?)
	if notReady(self) then return self end
	if typeof(self.Value) ~= "Instance" then return fail(self, message or "Tag requires an Instance") end
	return check(self, CollectionService:HasTag(self.Value :: Instance, tag), message or ("Missing tag \"" .. tag .. "\""))
end

-- ===== Table methods =====

function Methods:IsArray(message: string?)
	if notReady(self) then return self end
	if type(self.Value) ~= "table" then return fail(self, message or "IsArray requires a table") end
	local t = self.Value :: {[any]: any}
	local count = 0
	for _ in pairs(t) do count += 1 end
	return check(self, count == #t, message or "Value is not a sequential array")
end

function Methods:Each(validator: (value: any, key: any) -> boolean, message: string?)
	if notReady(self) then return self end
	if type(self.Value) ~= "table" then return fail(self, message or "Each requires a table") end
	for k, v in pairs(self.Value :: {[any]: any}) do
		local ok, result = pcall(validator, v, k)
		if not ok or result ~= true then
			return fail(self, message or ("Element failed validation at key " .. tostring(k)))
		end
	end
	return self
end

function Methods:Frozen(message: string?)
	if notReady(self) then return self end
	if type(self.Value) ~= "table" then return fail(self, message or "Frozen requires a table") end
	return check(self, table.isfrozen(self.Value :: {}), message or "Table is not frozen")
end

-- ===== Function methods =====

function Methods:Callable(message: string?)
	return check(self, type(self.Value) == "function", message or "Value is not callable")
end

function Methods:Arity(expected: number, message: string?)
	if notReady(self) then return self end
	if type(self.Value) ~= "function" then return fail(self, message or "Arity requires a function") end
	local numparams: number = debug.info(self.Value :: (...any) -> ...any, "a")
	return check(self, numparams == expected, message or ("Function does not have arity " .. tostring(expected)))
end

local function createNamespace(data: any)
	return setmetatable({}, {
		__index = function(_, k)
			if Methods[k] then
				return Methods[k]
			end
			return data[k]
		end,
		__newindex = function(_, k, v)
			data[k] = v
		end,
	})
end

local Guard = {}

local function create(value: any): GuardWrapper
	local data = {
		Value = value,
		Valid = true,
		_errors = {},
		_skipped = false,
	}

	local namespaces = {
		StringGuard = createNamespace(data),
		NumberGuard = createNamespace(data),
		BooleanGuard = createNamespace(data),
		InstanceGuard = createNamespace(data),
		TableGuard = createNamespace(data),
		FunctionGuard = createNamespace(data),
	}
	return (setmetatable({}, {
		__index = function(_, k)
			if namespaces[k] then
				return namespaces[k]
			end
			if Methods[k] then
				return Methods[k]
			end
			return data[k]
		end,
		__newindex = function(_, k, v)
			data[k] = v
		end,
	}) :: any) :: GuardWrapper
end

function Guard.Is(value: any, luaType: string): boolean
	return type(value) == luaType
end

function Guard.TypeOf(value: any, expected: string): boolean
	return typeof(value) == expected
end

return setmetatable(Guard, {
	__call = function(_, value: any)
		return create(value)
	end,
})
