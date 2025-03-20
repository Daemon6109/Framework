--------------------------------------------------------------------------------
-- FrameworkInit.spec.luau
-- Unit tests for Framework initialization behavior
-- @Daemon6109 (Matthew Radulovich)
--------------------------------------------------------------------------------

local Framework = require("@Project")
local JestGlobals = require("@Packages/JestGlobals")

local loadModules = require("Utils/loadModules")

local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local it = JestGlobals.it
local jest = JestGlobals.jest

describe("Framework Initialization", function()
	local mockProviders = loadModules:fromChildren(script.Parent.Parent.__mocks__)
	for _, provider in mockProviders do
		provider.init = jest.fn()
		provider.start = jest.fn()
	end
	beforeEach(function()
		Framework.STARTED = false
		Framework.PROFILING = false
		Framework.ADDED_PROVIDERS = table.clear(Framework.ADDED_PROVIDERS)
		Framework.INITIATED_PROVIDERS = table.clear(Framework.INITIATED_PROVIDERS)
		mockProviders = {}
	end)

	it("should set STARTED to true after initialization", function()
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
		Framework:add(mockProviders)
		expect(#Framework.ADDED_PROVIDERS).toBe(#mockProviders)
	end)

	it("should initialize and start providers in order", function()
		Framework:add(mockProviders)
		Framework:init()

		for _, provider in Framework.ADDED_PROVIDERS do
			expect(provider.init).toHaveBeenCalledTimes(1)
			expect(provider.start).toHaveBeenCalledTimes(1)
		end
	end)

	it("should handle errors in provider initialization gracefully", function()
		Framework:add(mockProviders)
		expect(function()
			Framework:init()
		end).toThrow()
	end)
end)
