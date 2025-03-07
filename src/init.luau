-------------------------------------------------------------------------------
-- framework.luau
-- A framework for managing providers in Roblox with dependency handling and profiling.
--------------------------------------------------------------------------------

local version = { major = 1, minor = 0, patch = 0 }

local debugger = require(script.Parent.roblox_packages.debugger)

-- Define the Provider type with specific fields
type Provider = {
	init: (() -> ())?, -- Optional initialization function
	name: string, -- Name of the provider
	start: (() -> ())?, -- Optional start function
}

local assert: <T>(T, string, ...any) -> T = debugger.assert
local fatal = debugger.fatal

-- Framework object to manage providers
local framework = {
	STARTED = false, -- Tracks if the framework has started
	PROFILING = false, -- Enables memory profiling if true
	ADDED_PROVIDERS = {} :: { Provider }, -- Stores all added providers
	INITIATED_PROVIDERS = {} :: { Provider }, -- Stores providers that have been initialized

	-- Centralized error messages
	LOGS = {
		AlreadyStarted = "Framework has already started",
		FatalInit = "Init errored: %s",
		FatalAddModule = "Added module errored: %s",
		ReservedName = "'%s' is a reserved %s name",
		InvalidType = "Expected type %s; got '%s'",
	},
}

type Framework = typeof(framework)

--[=[
	@method IsInitiated
	@within Framework
	@param provider: Provider
	@return boolean
	Helper function to check if a provider has been initiated
]=]
function framework.IsInitiated(self: Framework, provider: Provider): boolean
	return table.find(self.INITIATED_PROVIDERS, provider) ~= nil
end

--[=[
    @method StartProvider
    @within Framework 
    @param provider: Provider
    Starts the provider if it has a start function.
]=]
function framework.StartProvider(self: Framework, provider: Provider)
	if provider.start then
		local argType = type(provider.start)
		assert(argType == "function", "InvalidType", "function", argType)
		if self.PROFILING then
			debug.setmemorycategory(provider.name)
		end
		provider.start()
	end
end

--[=[
    @method InitProvider
    @within Framework 
    @param provider: Provider
    Initializes the provider if it has an init function and hasn't been initiated yet.
]=]
function framework.InitProvider(self: Framework, provider: Provider)
	if provider.init and not self:IsInitiated(provider) then
		local argType = type(provider.init)
		assert(argType == "function", "InvalidType", "function", argType)
		local success, result: debugger.ParsedError = xpcall(function()
			if self.PROFILING then
				debug.setmemorycategory(provider.name)
			end
			provider.init()
		end, debugger.parse)
		if not success then
			fatal("FatalInit", result.Message)
		end
	end
	table.insert(self.INITIATED_PROVIDERS, provider)
end

--[=[
    @method Add
    @within Framework
    @param providers: { Instance }
    Adds providers to the framework to be initialized and started.

	```lua
	framework.add({
		script.Parent.MyProvider,
	})
	```
]=]
function framework.Add(providers: { Instance })
	assert(not framework.STARTED, "AlreadyStarted")
	for _, module in providers do
		if not module:IsA("ModuleScript") then
			continue
		end
		local success, result = pcall(require, module)
		assert(success, "FatalAddModule", result)
		assert(type(result) == "table", "InvalidType", "table", type(result))
		result.name = module.Name
		result.order = result.order or 1
		table.insert(framework.ADDED_PROVIDERS, result)
	end
end

--[=[
    @method Start
    @within Framework
    @param config: { Profiling: boolean? }
    Starts the framework, initializing and starting all providers.

	```lua
	framework.start({
		Profiling = true,
	})
	```
]=]
function framework.Start(config: { Profiling: boolean? }?)
	assert(not framework.STARTED, "AlreadyStarted")
	if config then
		framework.PROFILING = config.Profiling or framework.PROFILING
	end
	for _, provider in framework.ADDED_PROVIDERS do
		framework:InitProvider(provider)
	end
	for _, provider in framework.INITIATED_PROVIDERS do
		framework:StartProvider(provider)
	end
	framework.STARTED = true
	table.freeze(framework.ADDED_PROVIDERS)
end

-- Debugger

debugger.set("Framework", framework.LOGS, "https://lumin-org.github.io/framework/guide/errors#")

-- Return the framework API
return {
	version,
	start = framework.Start,
	add = framework.Add,
}
