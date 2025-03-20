--------------------------------------------------------------------------------
-- Framework.spec
-- Unit tests for Framework initialization behavior
-- @Daemon6109 (Matthew Radulovich)
--------------------------------------------------------------------------------

local Framework = require("@Project")
local JestGlobals = require("@Packages/JestGlobals")

local mocks = script.Parent.Parent.__mocks__

local loadModules = require("./Utils/loadModules")

local mockProviders = loadModules:fromChildren(mocks)

local describe = JestGlobals.describe
local beforeAll = JestGlobals.beforeAll
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local it = JestGlobals.it
local jest = JestGlobals.jest

describe("Framework Initialization", function()
	beforeEach(function()
		Framework.STARTED = false
		Framework.PROFILING = false
		Framework.ADDED_PROVIDERS = {}
		Framework.INITIATED_PROVIDERS = {}
	end)

	it("should set STARTED to true after initialization", function()
		Framework:init()
		expect(Framework.STARTED).toBe(true)
	end)

	it("should prevent modification of ADDED_PROVIDERS after initialization", function()
		Framework:init()
		expect(function()
			table.insert(Framework.ADDED_PROVIDERS, { name = "NewProvider" })
		end).toThrow()
	end)

	it("should add providers correctly", function()
		Framework:add(mocks:GetChildren())
		expect(#Framework.ADDED_PROVIDERS).toBe(#mocks:GetChildren())
	end)

	it("should initialize and start providers in order", function()
		Framework:add(mocks:GetChildren())
		Framework:init()

		for _, provider in mockProviders do
			expect(provider.INIT_CALLED).toHaveBeenCalledTimes(1)
			expect(provider.STARTED_CALLED).toHaveBeenCalledTimes(1)
		end
	end)
end)
