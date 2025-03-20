-------------------------------------------------------------------------------
-- Framework
-- @Daemon6109 (Matthew Radulovich)
--------------------------------------------------------------------------------

local version = { major = 11, minor = 0, patch = 0 }

local Debugger = require("@Packages/Debugger")

--[=[
	Framework
	A simple framework for managing providers in Roblox with initialization and startup sequencing.
	Providers are initialized and started in the order specified by their `order` field.
	Each provider can have optional `init` and `start` functions. Providers can require other providers
	they depend on within their `init` or `start` methods as needed.
	Memory profiling can be enabled for debugging purposes.
	
	Usage:
	1. Create providers as ModuleScripts that return a table with optional `init`, `start`, and `order`.
	2. Add providers using Framework.add({provider1, provider2, ...})
	3. Initialize the framework using Framework.init({Profiling = true/false})
	
	Note: The `init` and `start` methods are called synchronously in the specified order. If a provider
	depends on another, it should require that provider within its own `init` or `start` method.

	@class Framework
]=]
local Framework = {
	version,

	STARTED = false, -- Tracks if the framework has started
	PROFILING = false, -- Enables memory profiling if true
	ADDED_PROVIDERS = {} :: { Provider }, -- Stores all added providers
	INITIATED_PROVIDERS = {} :: { Provider }, -- Stores providers that have been initialized

	-- Centralized error messages
	LOGS = {
		ALREADY_STARTED = "Framework has already started",
		FATAL_INIT = "Init errored: %s",
		FATAL_ADD_MODULE = "Added module errored: %s",
		INVALID_TYPE = "Expected type %s; got '%s'",
	},
}
export type Framework = {
	version: { major: number, minor: number, patch: number },
	add: (self: Framework, { Instance }) -> (),
	init: (self: Framework, { Profiling: boolean? }?) -> (),
}

type FrameworkInternal = {
	STARTED: boolean,
	PROFILING: boolean,
	ADDED_PROVIDERS: { Provider },
	INITIATED_PROVIDERS: { Provider },
	LOGS: { [string]: string },
	isInitiated: (self: FrameworkInternal, Provider) -> boolean,
	startProvider: (self: FrameworkInternal, Provider) -> (),
	initProvider: (self: FrameworkInternal, Provider) -> (),
	add: (self: FrameworkInternal, { Instance }) -> (),
	init: (self: FrameworkInternal, { Profiling: boolean? }) -> (),
}

--[=[
	A provider that can be added to the framework.
	Providers can have optional `init` and `start` functions that are called in order.
	`init` is called once and `start` is called every time the framework is started.
	`order` can be used to specify the order in which providers are initialized and started.

	@private
	@within Framework
	@interface Provider
	.init? (() -> ()) -- Optional initialization function
	.name string -- Name of the provider
	.start? (() -> ()) -- Optional start function
	.order? number -- Optional order for initialization and starting
]=]
type Provider = {
	init: (() -> ())?, -- Optional initialization function
	name: string, -- Name of the provider
	start: (() -> ())?, -- Optional start function
	order: number?, -- Optional order for initialization and starting
}

local assert = Debugger.assert
local fatal = Debugger.fatal

--[=[
	Checks if a provider has been initiated.

	@private
	@method isInitiated
	@within Framework
	@param provider Provider -- The provider to check
	@return boolean -- True if the provider has been initiated

	```lua
	local initiated = Framework:isInitiated(provider)
	```
]=]
function Framework.isInitiated(self: FrameworkInternal, provider: Provider): boolean
	return table.find(self.INITIATED_PROVIDERS, provider) ~= nil
end

--[=[
	Starts the provider if it has a start function.

	@private
	@method startProvider
	@within Framework 
	@param provider Provider -- The provider to start

	```lua
	Framework:startProvider(provider)
	```
]=]
function Framework.startProvider(self: FrameworkInternal, provider: Provider)
	if provider.start then
		local argType = type(provider.start)
		assert(argType == "function", "INVALID_TYPE", "function", argType)
		if self.PROFILING then
			debug.setmemorycategory(provider.name)
		end
		provider.start()
	end
end

--[=[
	Initializes the provider if it has an init function and hasn't been initiated yet.

	@private
	@method initProvider
	@within Framework 
	@param provider Provider -- The provider to initialize

	```lua
	Framework:initProvider(provider)
	```
]=]
function Framework.initProvider(self: FrameworkInternal, provider: Provider)
	if provider.init and not self:isInitiated(provider) then
		local argType = type(provider.init)
		assert(argType == "function", "INVALID_TYPE", "function", argType)
		local success, result: Debugger.Parsed = xpcall(function()
			if self.PROFILING then
				debug.setmemorycategory(provider.name)
			end
			provider.init()
		end, Debugger.parse)
		if not success then
			fatal("FATAL_INIT", result.message)
		end
	end
	table.insert(self.INITIATED_PROVIDERS, provider)
end

--[=[
	Adds providers to the framework to be initialized and started.

	@method add
	@within Framework
	@param providers {Instance} -- A list of providers to add

	```lua
	Framework:add({ provider1, provider2 })
	```
]=]
function Framework.add(self: FrameworkInternal, providers: { Instance })
	assert(not self.STARTED, "ALREADY_STARTED")
	for _, module in providers do
		if not module:IsA("ModuleScript") then
			warn(string.format("Skipping non-ModuleScript instance: %s", module.Name))
			continue
		end
		local success, result = pcall(require, module)
		if not success then
			fatal("FATAL_ADD_MODULE", result)
		end
		assert(type(result) == "table", "INVALID_TYPE", "table", type(result))
		result.name = module.Name
		result.order = result.order or 1
		table.insert(self.ADDED_PROVIDERS, result)
	end
end

--[=[
	Initializes the framework, initializing and starting all providers in order.

	@method init
	@within Framework
	@param config {Profiling: boolean?} -- Optional configuration

	```lua
	Framework:init({ Profiling = true })
	```
]=]
function Framework.init(self: FrameworkInternal, config: { Profiling: boolean? }?)
	assert(not self.STARTED, "ALREADY_STARTED")
	if config then
		self.PROFILING = config.Profiling or self.PROFILING
	end
	-- Sort providers based on order
	table.sort(self.ADDED_PROVIDERS, function(a: Provider, b: Provider)
		return (a.order or 1) < (b.order or 1)
	end)
	-- Initialize providers
	for _, provider in self.ADDED_PROVIDERS do
		self:initProvider(provider)
	end
	-- Start providers
	for _, provider in self.ADDED_PROVIDERS do
		self:startProvider(provider)
	end
	self.STARTED = true
	table.freeze(self.ADDED_PROVIDERS)
end

-- Debugger setup
Debugger.set("Framework", Framework.LOGS, "https://lumin-org.github.io/framework/guide/errors#")

-- Return the framework API
return (Framework :: any) :: Framework
