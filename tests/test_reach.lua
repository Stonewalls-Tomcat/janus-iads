-- Doctrinal reach, EW-only cueing, Fire Can EMCON and the dry-battery latch (owner, 2026-10-17; Breakwater review:
-- an SA-10 came up on a 96 km cue from a 120 km DCS range, and an empty SA-10 was cued twice after running dry).
local F = dofile("tests/fake_dcs.lua")
local JANUS_FILE = arg and arg[1] or "dist/janus.lua"
local BLUE = coalition.side.BLUE
local AIR = Group.Category.AIRPLANE

local passed, failed = 0, 0
local function check(cond, msg)
  if cond then passed = passed + 1 else failed = failed + 1; print("  FAIL: " .. msg) end
end
local function load(settings)
  JANUS_SETTINGS = settings
  assert(loadfile(JANUS_FILE))()
  return JANUS
end
local function node(name) return JANUS.net.nodes[name] end
local freshReset = F.reset
F.reset = function()
  if JANUS then check(not F.logContains("ERROR JANUS"), "no Janus errors before a reset (t=" .. F.time .. ")") end
  freshReset()
end
local function bandit(name, x, z, alt)
  local g = F.addGroup{ name = name, coalition = BLUE, category = AIR, units = { { type = "F-16C_50", x = x, z = z, alt = alt or 6000 } } }
  return g.units[1]
end
-- CMD at 0, EW North at 20 km, SA-10 at 50 km (x north, metres)
local function base()
  F.addGroup{ name = "CMD Hama", units = { { type = "S-300PS 54K6 cp", x = 0, z = 0 } } }
  F.addGroup{ name = "EW North", units = { { type = "55G6 EWR", x = 20000, z = 0 } } }
end
local function sa10()
  return F.addGroup{ name = "SAM SA-10 Hama", units = { { type = "S-300PS 40B6M tr", x = 50000, z = 0 },
    { type = "S-300PS 5P85C ln", x = 50300, z = 0 } } }
end

-- ---------------------------------------------------------------- 1. the table and the settings
do
  F.reset()
  local J = load()
  check(J.reachAt(75000, 40000, 6000) == 75000 and J.reachAt(75000, 40000, 500) == 40000, "reachAt: hi high, lo low")
  check(J.reachAt(75000, 40000, 2000) == 57500, "reachAt: linear between REACH_LOW and REACH_HIGH")
  check(J.reachAt(75000, 40000, J.REACH_HIGH) == 75000 and J.reachAt(75000, 40000, J.REACH_LOW) == 40000, "reachAt: band edges")
  check(J.reachAt(24000, nil, 100) == 24000 and J.reachAt(24000, 30000, 100) == 24000 and J.reachAt(75000, 40000, nil) == 75000,
    "reachAt: no lo, lo above hi, or unknown height: hi")
  check(J.reachFor("S-300PS 5P85C ln").hi == 75000 and J.reachFor("F-16C_50") == nil, "reachFor: the table")
  for t, r in pairs(J.Reach) do
    check(r.hi == nil or r.lo == nil or r.lo < r.hi, "lo below hi: " .. t)
    check(r.hi ~= nil or r.track ~= nil, "every entry has a reach or a tracking range: " .. t)
  end
  F.reset()
  J = load({ REACH = false })
  check(J.reachFor("S-300PS 5P85C ln") == nil, "REACH = false: DCS figures only")
  F.reset()
  J = load({ REACH = { ["S-300PS 5P85C ln"] = { hi = 90000 }, ["KS-19"] = false } })
  check(J.reachFor("S-300PS 5P85C ln").hi == 90000 and J.reachFor("KS-19") == nil and J.reachFor("Kub 2P25 ln").hi == 24000,
    "REACH table: replaces or removes single entries, keeps the rest")
end

-- ---------------------------------------------------------------- 2. the network and the WTA read it
do
  F.reset()
  base(); sa10()
  F.addGroup{ name = "AAA KS-19 Belt", units = { { type = "SON_9", x = 30000, z = 5000 }, { type = "KS-19", x = 30100, z = 5000 } } }
  local J = load()
  F.run(5)
  local s = node("SAM SA-10 Hama")
  check(s.engageRange == 75000 and s.engageLow == 40000, "SA-10 engage range 75 km (DCS 120 km), low 40 km")
  local env = J.wta.envelope(s)
  check(env.R == 75000 and env.Rlo == 40000, "WTA envelope carries hi and lo")
  local function track(x, alt) return { pos = { x = x, y = alt, z = 0 } } end
  check(J.wta.pk(s, track(115000, 6000), 0) > 0 and J.wta.pk(s, track(115000, 500), 0) == 0,
    "65 km: in reach of a high target, out of reach of a low one")
  check(J.wta.pk(s, track(130000, 9000), 0) == 0, "80 km: beyond the 75 km reach (DCS 120 km would bid)")
  local reach, ceiling = J.aaa.reach(node("AAA KS-19 Belt"))
  check(reach == 12000 and ceiling == 11000, "KS-19: effective 12 km / 11 km, not the ballistic 20 km")
  F.reset()
  base(); sa10()
  J = load({ REACH = false })
  F.run(5)
  check(node("SAM SA-10 Hama").engageRange == 120000 and node("SAM SA-10 Hama").engageLow == 120000, "REACH = false: DCS 120 km")
end

-- ---------------------------------------------------------------- 3. EW-only cue: other radars do not wake a dark SAM
do
  F.reset()
  base(); sa10()
  F.addGroup{ name = "PD Tor [emcon:always]", units = { { type = "Tor 9A331", x = 95000, z = 2000 } } }
  local b = bandit("Viper 1", 100000, 0)        -- 50 km from the SA-10, high: inside the 0.8 x 75 = 60 km ring
  load()
  F.sees["PD Tor [emcon:always]"] = { b }
  F.run(60)
  check(not F.emitting("SAM SA-10 Hama"), "a Tor's plot inside the ring does not bring the SA-10 up (SOVIET: EW only)")
  check(F.logContains("SAM SA-10 Hama") and node("SAM SA-10 Hama").assigned ~= nil, "the crew is assigned and ready")
  F.sees["EW North"] = { b }
  F.run(100)
  check(F.emitting("SAM SA-10 Hama"), "the EW's plot inside the ring brings it up")
  check(F.logContains("SAM SA-10 Hama ON (assigned T"), "ON logged")
end
do
  F.reset()
  base(); sa10()
  F.addGroup{ name = "PD Tor [emcon:always]", units = { { type = "Tor 9A331", x = 95000, z = 2000 } } }
  local b = bandit("Viper 1", 100000, 0)
  load({ RED_DOCTRINE = { base = "SOVIET_PVO_1985", cueSource = "any" } })
  F.sees["PD Tor [emcon:always]"] = { b }
  F.run(60)
  check(F.emitting("SAM SA-10 Hama"), "cueSource any: the Tor's plot is enough")
end
do
  F.reset()
  base(); sa10()
  local b = bandit("Viper 1", 120000, 0)        -- 70 km: assigned (in reach) but outside the 60 km ring
  load()
  F.sees["EW North"] = { b }
  F.run(60)
  check(node("SAM SA-10 Hama").assigned ~= nil, "70 km high: assigned (inside the 75 km reach)")
  check(not F.emitting("SAM SA-10 Hama"), "70 km high: dark (ring 60 km)")
  F.move(b, 105000, 0)                          -- 55 km
  F.run(100)
  check(F.emitting("SAM SA-10 Hama"), "55 km high: up")
end
do
  F.reset()
  base(); sa10()
  local b = bandit("Low 1", 85000, 0, 300)      -- 35 km, 300 m: ring 0.8 x 40 = 32 km
  load()
  F.sees["EW North"] = { b }
  F.run(60)
  check(not F.emitting("SAM SA-10 Hama"), "low target at 35 km: dark (low ring 32 km)")
  F.move(b, 78000, 0)                           -- 28 km
  F.run(100)
  check(F.emitting("SAM SA-10 Hama"), "low target at 28 km: up")
end
do
  -- the EW's plot is old: no cue from a stale plot
  F.reset()
  base(); sa10()
  local b = bandit("Viper 1", 100000, 0)
  local J = load()
  F.sees["EW North"] = { b }
  F.run(8)
  local tr
  for _, t in pairs(J.net.networks["red/main"].tracks or {}) do tr = t end
  check(tr and J.tracks.ewPlot(tr, F.time) ~= nil, "fresh EW plot")
  check(tr and J.tracks.ewPlot(tr, F.time + J.tracks.EW_FRESH + 1) == nil, "an EW plot older than EW_FRESH is no cue")
end

-- ---------------------------------------------------------------- 4. dry battery latch
do
  F.reset()
  base()
  local g = sa10()
  local ln = g.units[2]
  ln.ammo = 0
  local b = bandit("Viper 1", 100000, 0)
  local J = load()
  F.sees["EW North"] = { b }
  F.run(60)
  check(F.logContains("SAM SA-10 Hama out of missiles"), "out of missiles logged")
  check(not F.emitting("SAM SA-10 Hama"), "an empty SA-10 is not cued")
  ln.ammo = 4                                   -- DCS reports rounds again on spent launchers (Breakwater)
  F.run(100)
  check(not F.emitting("SAM SA-10 Hama"), "held dry although DCS reports missiles again")
  check(F.logContains("held dry until it fires"), "the DCS oddity is logged")
  local lines = 0
  for _, l in ipairs(F.log) do if l:find("held dry until it fires", 1, true) then lines = lines + 1 end end
  check(lines == 1, "logged once (" .. lines .. ")")
  F.launch{ shooter = ln, type = "SA5B55", x = 50300, z = 0, vx = 1000 }
  check(F.logContains("SAM SA-10 Hama rearmed (launched again)"), "a launch clears the latch")
  check(node("SAM SA-10 Hama").dry == nil, "not dry after the launch")
  ln.ammo = 0
  F.run(130)
  check(J.wta.rearm("SAM SA-10 Hama", "resupply") == true and F.logContains("rearmed (resupply)"), "JANUS.wta.rearm by name")
  check(J.wta.rearm("SAM SA-10 Hama") == false and J.wta.rearm("nobody") == false, "rearm of a loaded or unknown site: false")
end

-- ---------------------------------------------------------------- 5. Fire Can: cued by the EW inside its tracking ring
do
  F.reset()
  base()
  F.addGroup{ name = "AAA KS-19 Belt", units = { { type = "SON_9", x = 50000, z = 0 }, { type = "KS-19", x = 50100, z = 0 } } }
  local b = bandit("Viper 1", 90000, 0)         -- 40 km: inside the cue range, outside 0.8 x 35 = 28 km
  load()
  F.run(3)
  check(not F.emitting("AAA KS-19 Belt"), "SOVIET: the Fire Can starts dark (cued EMCON), not always on")
  F.sees["EW North"] = { b }
  F.run(60)
  check(not F.emitting("AAA KS-19 Belt"), "40 km: still dark")
  F.move(b, 75000, 0)                           -- 25 km
  F.run(100)
  check(F.emitting("AAA KS-19 Belt"), "25 km: the Fire Can comes up to track before the guns reach")
  F.move(b, 300000, 0)
  F.run(200)
  check(not F.emitting("AAA KS-19 Belt"), "target gone: dark again after the cue hold")
  F.killGroup(F.groups["EW North"])
  F.run(260)
  check(F.emitting("AAA KS-19 Belt"), "no EW cover: falls back to its own radar (autonomous always)")
end
do
  F.reset()
  base()
  F.addGroup{ name = "AAA KS-19 Belt", units = { { type = "SON_9", x = 50000, z = 0 }, { type = "KS-19", x = 50100, z = 0 } } }
  load({ RED_DOCTRINE = "GENERIC_THIRD_WORLD" })
  F.run(3)
  check(F.emitting("AAA KS-19 Belt"), "a doctrine without cued AAA keeps the Fire Can always on")
end

-- ---------------------------------------------------------------- 5a. geometry: site off the axis and on high ground
do
  -- SA-10 on a 1000 m plateau at z = 30 km; EW plot of a target 300 m above the site (low ring 0.8 x 40 = 32 km)
  local function site()
    F.reset()
    base()
    F.addGroup{ name = "SAM SA-10 Hill", units = { { type = "S-300PS 40B6M tr", x = 50000, z = 30000, alt = 1000 },
      { type = "S-300PS 5P85C ln", x = 50300, z = 30000, alt = 1000 } } }
  end
  site()
  local b = bandit("Low 1", 50000, 65000, 1300)    -- 35 km east of the site, 300 m above it: outside the low ring
  load()
  F.sees["EW North"] = { b }
  F.run(60)
  check(not F.emitting("SAM SA-10 Hill"), "plateau site: a target 300 m above it at 35 km is low (dark)")
  F.move(b, 50000, 58000)                          -- 28 km east
  F.run(100)
  check(F.emitting("SAM SA-10 Hill"), "plateau site: 28 km east, inside the low ring: up")
  site()
  b = bandit("High 1", 50000, 85000, 5000)          -- 55 km east, 4 km above the site: inside the 60 km high ring
  load()
  F.sees["EW North"] = { b }
  F.run(60)
  check(F.emitting("SAM SA-10 Hill"), "plateau site: a high target 55 km east is inside the high ring")
end

-- ---------------------------------------------------------------- 5b. a gun radar without a tracking range, and REACH overrides on guns
do
  F.reset()
  base()
  F.addGroup{ name = "AAA QF Belt", units = { { type = "Allies_Director", x = 50000, z = 0 }, { type = "QF_37_AA", x = 50100, z = 0 } } }
  local b = bandit("Viper 1", 62000, 0)           -- 12 km: outside 0.8 x the 9 km gun reach
  load()
  F.sees["EW North"] = { b }
  F.run(60)
  check(not F.emitting("AAA QF Belt"), "a director with no tracking range waits for the gun ring (12 km: dark)")
  F.move(b, 56000, 0)                              -- 6 km
  F.run(100)
  check(F.emitting("AAA QF Belt"), "6 km: inside 0.8 x 9 km: up")
  check(not F.logContains("ERROR JANUS"), "no errors")
end
do
  F.reset()
  base()
  F.addGroup{ name = "AAA KS-19 Belt", units = { { type = "SON_9", x = 50000, z = 0 }, { type = "KS-19", x = 50100, z = 0 } } }
  local J = load({ REACH = { ["KS-19"] = { hi = 30000, ceil = 5000 } } })
  F.run(3)
  local reach, ceiling = J.aaa.reach(node("AAA KS-19 Belt"))
  check(reach == 20000 and ceiling == 5000, "a REACH entry never raises the DCS reach (30 km asked, 20 km kept); ceil caps")
  F.reset()
  base()
  F.addGroup{ name = "AAA KS-19 Belt", units = { { type = "SON_9", x = 50000, z = 0 }, { type = "KS-19", x = 50100, z = 0 } } }
  J = load({ REACH = { ["KS-19"] = { ceil = 7000 } } })
  F.run(3)
  reach, ceiling = J.aaa.reach(node("AAA KS-19 Belt"))
  check(reach == 20000 and ceiling == 7000, "an entry with a ceiling only keeps the DCS reach")
  check(not F.logContains("ERROR JANUS"), "no errors with a ceiling-only entry")
  F.reset()
  base()
  F.addGroup{ name = "AAA KS-19 Belt", units = { { type = "SON_9", x = 50000, z = 0 }, { type = "KS-19", x = 50100, z = 0 } } }
  J = load({ REACH = { ["KS-19"] = { ceil = 25000 } } })
  F.run(3)
  reach, ceiling = J.aaa.reach(node("AAA KS-19 Belt"))
  check(reach == 20000 and ceiling == 20000, "a ceiling above the gun's own never raises it")
end
do
  -- the Fire Can is cued from 1.3 x its 35 km tracking range: at 27.5 km (inside the 28 km ring) it comes up
  F.reset()
  base()
  F.addGroup{ name = "AAA KS-19 Belt", units = { { type = "SON_9", x = 50000, z = 0 }, { type = "KS-19", x = 50100, z = 0 } } }
  local b = bandit("Viper 1", 77500, 0)
  load()
  F.sees["EW North"] = { b }
  F.run(60)
  check(F.emitting("AAA KS-19 Belt"), "27.5 km: cued (cue range 45.5 km) and inside the 28 km ring: up")
end

-- ---------------------------------------------------------------- 6. NATO / US: up before the zone, no ambush
do
  local RED = coalition.side.RED
  local function run(doctrine)
    F.reset()
    F.addGroup{ name = "CMD Blue", coalition = BLUE, units = { { type = "Patriot cp", x = 0, z = 0 } } }
    F.addGroup{ name = "EW Blue", coalition = BLUE, units = { { type = "FPS-117", x = 1000, z = 0 } } }
    F.addGroup{ name = "SAM Patriot", coalition = BLUE, units = { { type = "Patriot str", x = 0, z = 2000 },
      { type = "Patriot ECS", x = 100, z = 2000 }, { type = "Patriot ln", x = 300, z = 2000 } } }
    local g = F.addGroup{ name = "Flanker 1", coalition = RED, category = AIR, units = { { type = "Su-27", x = 200000, z = 2000, alt = 8000 } } }
    local b = g.units[1]
    load({ BLUE_DOCTRINE = doctrine })
    F.sees["EW Blue"] = { b }
    local upAt
    for t = 1, 140 do                            -- 250 m/s inbound, from 200 km
      F.move(b, 200000 - 1250 * t, 2000)
      F.run(t * 5)
      if not upAt and F.emitting("SAM Patriot") then upAt = 200000 - 1250 * t end
    end
    return upAt
  end
  local us = run("US_MODERN")
  check(us and us > 100000, "US_MODERN: the Patriot is up before the target reaches its 100 km zone (up at " .. tostring(us) .. " m)")
  local old = run({ base = "US_MODERN", ambush = 1.0 })
  check(old and old <= 100000, "with the old 1.0 ring it came up only inside 100 km (" .. tostring(old) .. " m)")
end

print(string.format("test_reach: %d passed, %d failed", passed, failed))
if failed > 0 then os.exit(1) end
