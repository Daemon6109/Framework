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

	beforeEach(function()
		print("Running beforeEach - Resetting Framework state")
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
				return mockProviders[module.Name]
			end
			error("Require failed for " .. module.Name)
		end)
		_G.debug = { setmemorycategory = jest.fn() }
	end)

	it("should set STARTED to true after initialization", function()
		print("STARTED before test:", Framework.STARTED)
		Framework:init()
		expect(Framework.STARTED).toBe(true)
	end)

	it("should prevent modification of ADDED_PROVIDERS after initialization", function()
		print("STARTED before test:", Framework.STARTED)
		Framework.ADDED_PROVIDERS = { { name = "Provider" } }
		Framework:init()
		expect(function()
			table.insert(Framework.ADDED_PROVIDERS, { name = "NewProvider" })
		end).toThrow()
	end)
end)
