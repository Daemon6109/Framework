--------------------------------------------------------------------------------
-- FrameworkInit.spec.luau
-- Unit tests for Framework initialization behavior
-- @Daemon6109 (Matthew Radulovich)
--------------------------------------------------------------------------------

local Framework = require("@Project")
local JestGlobals = require("@Packages/JestGlobals")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it
local beforeEach = JestGlobals.beforeEach
local jest = JestGlobals.jest

describe("Framework Initialization", function()
	local mockProviders

	local function createMockModuleScript(name, provider)
		return {
			Name = name,
			IsA = function(_, className)
				return className == "ModuleScript"
			end,
			GetFullName = function()
				return name
			end,
			provider = provider,
		}
	end

	beforeEach(function()
		-- print("Running beforeEach - Resetting Framework state")
		Framework.STARTED = false
		Framework.PROFILING = false
		Framework.ADDED_PROVIDERS = {}
		Framework.INITIATED_PROVIDERS = {}
		Framework.Debugger = {
			assert = function(condition, message)
				if not condition then
					error(message)
				end
			end,
			fatal = function(code, ...)
				error(Framework.LOGS[code]:format(...))
			end,
			parse = function(err)
				return { Message = err }
			end,
			set = function() end,
		}
		mockProviders = {}
		_G.require = jest.fn(function(module)
			if mockProviders[module.Name] then
				return mockProviders[module.Name].provider
			end
			error("Require failed for " .. module.Name)
		end)
		_G.debug = { setmemorycategory = jest.fn() }
	end)

	it("should set STARTED to true after initialization", function()
		-- print("STARTED before test:", Framework.STARTED)
		Framework:init()
		expect(Framework.STARTED).toBe(true)
	end)

	it("should prevent modification of ADDED_PROVIDERS after initialization", function()
		-- print("STARTED before test:", Framework.STARTED)
		Framework.ADDED_PROVIDERS = { { name = "Provider" } }
		Framework:init()
		expect(function()
			table.insert(Framework.ADDED_PROVIDERS, { name = "NewProvider" })
		end).toThrow()
	end)

	it("should add providers correctly", function()
		local provider1 = createMockModuleScript("Provider1", { init = jest.fn(), start = jest.fn() })
		local provider2 = createMockModuleScript("Provider2", { init = jest.fn(), start = jest.fn() })
		mockProviders = { Provider1 = provider1, Provider2 = provider2 }

		Framework:add({ provider1, provider2 })
		expect(#Framework.ADDED_PROVIDERS).toBe(2)
	end)

	it("should initialize and start providers in order", function()
		local provider1 = createMockModuleScript("Provider1", { init = jest.fn(), start = jest.fn(), order = 2 })
		local provider2 = createMockModuleScript("Provider2", { init = jest.fn(), start = jest.fn(), order = 1 })
		mockProviders = { Provider1 = provider1, Provider2 = provider2 }

		Framework:add({ provider1, provider2 })
		Framework:init()

		expect(provider2.provider.init).toHaveBeenCalledTimes(1)
		expect(provider1.provider.init).toHaveBeenCalledTimes(1)
		expect(provider2.provider.start).toHaveBeenCalledTimes(1)
		expect(provider1.provider.start).toHaveBeenCalledTimes(1)
	end)

	it("should handle errors in provider initialization gracefully", function()
		local provider = createMockModuleScript("Provider", {
			init = function()
				error("Init error")
			end,
		})
		mockProviders = { Provider = provider }

		Framework:add({ provider })
		expect(function()
			Framework:init()
		end).toThrow("Init error")
	end)

	it("should not allow adding providers after initialization", function()
		local provider = createMockModuleScript("Provider", { init = jest.fn(), start = jest.fn() })
		mockProviders = { Provider = provider }

		Framework:add({ provider })
		Framework:init()

		expect(function()
			Framework:add({ provider })
		end).toThrow("Framework has already started")
	end)
end)
