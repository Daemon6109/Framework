--------------------------------------------------------------------------------
-- provider1
--------------------------------------------------------------------------------

local version = { major = 1, minor = 0, patch = 0 }

--[=[
   This function is used to start the provider and initialize any necessary systems.

   ```lua
   provider1.start()
   ```
]=]
local function start()
	-- Initialize or start the provider logic here
end

--[=[
   This function is used for initialization. It should be called before `start()` to set up the provider.

   ```lua
   provider1.init()
   ```
]=]
local function init()
	-- Set up any initialization logic here
end

return {
	version = version,

	-- Functions
	start = start,
	init = init,
}
