--------------------------------------------------------------------------------
-- provider1
--------------------------------------------------------------------------------

local version = { major = 1, minor = 0, patch = 0 }

local JestGlobals = require(game:GetService('ReplicatedStorage').roblox_packages.JestGlobals)
local Jest = JestGlobals.jest

local STARTED_CALLED = Jest.fn()
local INIT_CALLED = Jest.fn()

--[=[
   This function is used to start the provider and initialize any necessary systems.

   ```lua
   provider1.start()
   ```
]=]
local function start()
	-- Initialize or start the provider logic here
	STARTED_CALLED()
end

--[=[
   This function is used for initialization. It should be called before `start()` to set up the provider.

   ```lua
   provider1.init()
   ```
]=]
local function init()
	-- Set up any initialization logic here
	INIT_CALLED()
end

return {
	version = version,

	-- Constants
	STARTED_CALLED = STARTED_CALLED,
	INIT_CALLED = INIT_CALLED,

	-- Functions
	start = start,
	init = init,
}
