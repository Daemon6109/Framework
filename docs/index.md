---
hide:
  - toc
  - navigation
---

# Lumin Framework

A lightning fast & efficient framework for Roblox

[Guides](./guides/){ .md-button .md-button--primary }
[Reference](./reference/){ .md-button }

## Primitive Providers

```luau
local Framework = require(Packages.framework)

local function Explode()
    print("KABOOM!!!")
end

return Framework.New {
    Explode = Explode,
}
```

Providers are nothing more than tables; no metatables or anything else are used.

## Organized Dependencies

```luau
local Framework = require(Packages.framework)
local Dependency = require(Modules.Dependency)

-- Init is called after other dependencies the module uses are loaded
local function Init()
    Dependency.NuclearExplosion() -- This dependency loads first and in result is usable!
end

return Framework.New {
    Uses = { Dependency },
    Init = Init,
}
```

Organizes your dependencies in an understandable way, so you can easily keep track of what your module uses.

## Straightforward Lifecycle Design

```luau
local Framework = require(Packages.framework)
local FrameLifecycle = Framework.Lifecycle("PostSimulation")

local function PostSimulation()
    print("I print every frame!")
end

return Framework.New {
    PostSimulation = PostSimulation,
}
```

Has a simple lifecycle design that is readable and accessible at a glance.

## Finally...

Try it out and see if you love it! It comes in a very small size and is easily embeddable into already existing game architecture; *no* extra dependencies are required. With built-in plugin support, a thriving community, and type safety, what's truly **not** to like about it?
