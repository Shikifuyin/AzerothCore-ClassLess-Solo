-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess Lib : OOP support for LUA
-------------------------------------------------------------------------------------------------------------------
-- Usage :
-- Declaration		  - MyClass = class()
-- Inheritance		  - MySubClass = class( MyBaseClass ), Methods can be overloaded !
-- Constructor		  - function MyClass:init( a, b, c )
--							self.sum = a+b+c -- Declare Members, can use getters/setters (see below)
--						end
-- Instanciation	  - local hInstance = MyClass( 1, 2, 3 )
--					  - local hInstance = MyClass:new( 1, 2, 3 )
-- Members			  - hInstance.sum
-- Static Members	  - MyClass.staticMember
-- Methods			  - function MyClass:MyMethod( a )
--							self.sum = self.sum + a
--						end
-- Method call		  - hInstance:MyMethod( 1 )
-- Static Method call - MyClass:MyMethod( 1 ) -- can only use static members
-- Add/Remove Members - MyClass:set( "property", value )
--					  - MyClass:set{ prop1 = value1, prop2 = nil }
-- Getters / Setters  - MyClass:set{
--							someMember = "blah",
--							getsetMember = {
--								value = "something",
--								get = function(self, value) return self.someMember .. value end,
--								set = function(self, newval, oldval) return self.someMember .. newval .. oldval end,
--								afterSet = function(self, newval) self.someMember = newval end
--							}
--						}
--						a = hInstance.getsetMember      -- Executes the get function, if defined
--						hInstance.getsetMember = "Duh!" -- Executes the set function, if defined, executes afterSet afterward, if defined
--						-- Can also use constant values instead of functions for 'get' and 'set' ...
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Requirements
local AIO = AIO or require("AIO")

-------------------------------------------------------------------------------------------------------------------
-- Client / Server Setup

-- Needed on both sides !
if AIO.IsServer() then
	AIO.AddAddon()
end

-------------------------------------------------------------------------------------------------------------------
-- Constants

-------------------------------------------------------------------------------------------------------------------
-- Class holder
Class = {}

-------------------------------------------------------------------------------------------------------------------
-- Default Constructor
function Class:init( ... )
	-- Nothing to do !
end

-------------------------------------------------------------------------------------------------------------------
-- Declaration & Inheritance
function Class:extend( hObject )
	local hObject = hObject or {}
	
	-- Inherit from hObject
	local function tableDeepCopy( arrDest, arrSrc )
		local arrResult = arrDest or {}
		local arrSrc = arrSrc or {}
		
		for key, value in pairs(arrSrc) do
			if ( not arrResult[key] ) then
				if ( type(value) == "table" and key ~= "__index" and key ~= "__newindex" ) then
					arrResult[key] = tableDeepCopy( nil, value )
				else
					arrResult[key] = value
				end
			end
		end
		
		return arrResult
	end

	tableDeepCopy( hObject, self )
	
	-- Properties storage
	hObject._ = hObject._ or {}
	
	-- Setup Metatable
	local hMT = {}
	
	-- Direct object creation : hInstance = MyClass()
	hMT.__call = function( self, ... )
		return self:new(...)
	end
	
	-- Getters
	hMT.__index = function( hTable, hKey )
		local hValue = rawget( hTable._, hKey )
		if ( hValue ~= nil and type(hValue) == "table" and (hValue.get ~= nil or hValue.value ~= nil) ) then
			-- table value case
			if ( hValue.get ~= nil ) then
				if ( type(hValue.get) == "function" ) then
					-- get function case
					return hValue.get( hTable, hValue.value )
				else
					-- get constant case
					return hValue.get
				end
			elseif ( hValue.value ~= nil ) then
				-- get not defined
				return hValue.value
			end
		else
			-- simple value case
			return hValue
		end
	end
	
	-- Setters
	hMT.__newindex = function( hTable, hKey, hNewValue )
		local hValue = rawget( hTable._, hKey )
		if ( hValue ~= nil and type(hValue) == "table" and ((hValue.set ~= nil and hValue._ == nil) or hValue.value ~= nil) ) then
			-- table value case
			local hTmp = hNewValue
			if ( hValue.set ~= nil ) then
				if type(hValue.set) == "function" then
					-- Class case
					hTmp = hValue.set(hTable, hNewValue, hValue.value)
				else
					-- just a member with name 'set'
					hTmp = hValue.set
				end
			end
			hValue.value = hTmp
			if ( hValue ~= nil and hValue.afterSet ~= nil ) then
				hValue.afterSet( hTable, hTmp )
			end
		else
			-- simple value case
			hTable._[hKey] = hNewValue
		end
	end
	
	-- Done !
	setmetatable( hObject, hMT )
	return hObject
end

-------------------------------------------------------------------------------------------------------------------
-- Instanciation
function Class:new( ... )
	local hObject = self:extend( {} )
	if ( hObject.init ~= nil ) then
		hObject:init( ... )
	end
	return hObject
end

function class( hBaseObject )
	hBaseObject = hBaseObject or {}
	return Class:extend( hBaseObject )
end

-------------------------------------------------------------------------------------------------------------------
-- Dynamic Properties 
function Class:set( hProperty, hValue )
	if ( hValue == nil and type(hProperty) == "table" ) then
		for key, value in pairs(hProperty) do
			rawset( self._, key, value )
		end
	else
		rawset( self._, hProperty, hValue )
	end
end



