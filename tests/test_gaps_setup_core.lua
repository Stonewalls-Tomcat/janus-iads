-- Setup report and core utilities: checks for paths the full mutation gate of 2026-10-17 found untested.
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
local function count(pattern)
  local n = 0
  for _, l in ipairs(F.log) do if l:find(pattern, 1, true) then n = n + 1 end end
  return n
end

-- a DCS type per unit role (first by name, no DLC)
F.reset()
local J0 = load()
local byRole = {}
do
  local names = {}
  for t in pairs(J0.UnitDB) do names[#names + 1] = t end
  table.sort(names)
  for _, t in ipairs(names) do
    local r = J0.UnitDB[t]
    if r.role and not byRole[r.role] and not r.dlc then byRole[r.role] = t end
  end
end
local EXPECT = {   -- janus_setup EXPECT
  SAM   = { shooters = { "LN", "TELAR", "SHORAD", "MANPADS" }, sensors = { "TR", "STR", "TELAR", "SHORAD" } },
  PD    = { shooters = { "SHORAD", "TELAR", "CRAM", "MANPADS" }, sensors = { "SHORAD", "TELAR", "CRAM", "SR" } },
  AAA   = { shooters = { "AAA" }, sensors = { "AAA_FC", "AAA" } },
  EW    = { sensors = { "EWR", "SR", "STR" } },
  CMD   = { c2 = { "C2", "C2_GENERIC" } },
  SHIP  = { shooters = { "NAVAL_AD" }, sensors = { "NAVAL_AD" } },
  AWACS = { sensors = { "AIRBORNE_SENSOR" } },
}
local PROBLEM = { shooters = "has no launcher or gun", sensors = "has no radar or sensor of its own", c2 = "has no command-post unit" }
local FILLER = { shooters = "sensors", sensors = "shooters" }

-- ---------------------------------------------------------------- 1. what each role word expects
-- one unit of the role alone: the matching problem line must be absent (the other one may well appear)
for word, exp in pairs(EXPECT) do
  for what, roles in pairs(exp) do
    for _, role in ipairs(roles) do
      F.reset()
      local cat = word == "AWACS" and AIR or nil
      F.addGroup{ name = word .. " Probe", category = cat, units = { { type = byRole[role], x = 0, z = 0 } } }
      load()
      F.run(2)
      check(count("PROBLEM: " .. word .. " Probe " .. PROBLEM[what]) == 0,
        word .. ": a " .. role .. " (" .. tostring(byRole[role]) .. ") alone satisfies '" .. what .. "'")
    end
    F.reset()
    local cat = word == "AWACS" and AIR or nil
    F.addGroup{ name = word .. " Probe", category = cat, units = { { type = "Ural-375", x = 0, z = 0 } } }
    load()
    F.run(2)
    check(count("PROBLEM: " .. word .. " Probe " .. PROBLEM[what]) == 1, word .. " without " .. what .. ": problem reported")
  end
end
-- a role that is not on the list does not satisfy it
do
  F.reset()
  F.addGroup{ name = "SAM Probe", units = { { type = byRole.SR, x = 0, z = 0 } } }
  load()
  F.run(2)
  check(count("PROBLEM: SAM Probe has no radar or sensor of its own") == 1, "a search radar alone is no SAM fire-control sensor")
end
do
  F.reset()
  F.addGroup{ name = "SAM Empty", units = { { type = "ZIL-131 KUNG", x = 0, z = 0 } } }
  load()
  F.run(2)
  check(count("PROBLEM: SAM Empty has no launcher or gun") == 1 and count("PROBLEM: SAM Empty has no radar or sensor of its own") == 1,
    "both problems listed for a group with neither")
end

-- ---------------------------------------------------------------- 2. notes, unrecognised groups, report header, DLC
do
  F.reset()
  F.addGroup{ name = "SAM Odd", units = { { type = "Kub 1S91 str", x = 0, z = 0 }, { type = "Kub 2P25 ln", x = 100, z = 0 }, { type = "Mystery Box", x = 200, z = 0 } } }
  F.addGroup{ name = "Battery 1", units = { { type = "Kub 1S91 str", x = 5000, z = 0 }, { type = "Kub 2P25 ln", x = 5100, z = 0 }, { type = "Ural-375", x = 5200, z = 0 } } }
  F.addGroup{ name = "Fleet", units = { { type = "MOSCOW", x = 9000, z = 0 }, { type = "ELNYA", x = 9100, z = 0 } } }
  F.addGroup{ name = "AAA Flak", units = { { type = "flak18", x = 20000, z = 0 }, { type = "KDO_Mod40", x = 20100, z = 0 } } }
  local J = load({ CHECK_MODE = true })
  F.run(2)
  check(F.logContains("unit type 'Mystery Box' is not in the Janus unit database (ignored)"), "an unknown type is noted")
  check(F.logContains("'Battery 1' (2 AD units)"), "an unnamed group: its air-defence units counted (not the truck)")
  check(F.logContains("'Fleet' (1 AD units)"), "ships: only the air-defence ship counts")
  check(F.logContains("Janus IADS " .. J.VERSION .. " setup report (DCS unit data " .. J.UnitDBMeta.dcsVersion .. ")"), "report header: version and DCS data")
  check(F.logContains("uses 'KDO_Mod40', a DCS: WWII Assets Pack unit") and F.logContains("This mission uses DCS: WWII Assets Pack units"),
    "DLC units noted per site and once for the mission")
  check(#F.text >= 1 and F.textSecs == 30, "CHECK_MODE: report on screen for 30 s")
  check(type(J.scan()) == "table", "scan returns the site list")
end

-- ---------------------------------------------------------------- 3. start: modules, doctrine names, twice
do
  F.reset()
  F.addGroup{ name = "EW N", units = { { type = "55G6 EWR" } } }
  local J = load({ AUTOSTART = false, RED_DOCTRINE = { base = "SOVIET_PVO_1985", ambush = 0.5 } })
  for _, mod in ipairs({ "net", "tracks", "wta", "emcon", "arm", "aaa", "gci", "api", "statsMod", "warning", "debugview" }) do
    check(J[mod] and type(J[mod].start) == "function", "module " .. mod .. " has start")
  end
  J.start({ blue = "NATO_COLDWAR" })
  check(F.logContains("started: red doctrine custom, blue doctrine NATO_COLDWAR, 1 sites"), "start: doctrine names, custom tables as 'custom'")
  J.start()
  check(F.logContains("JANUS.start() called twice; ignored"), "a second start is refused")
end

-- ---------------------------------------------------------------- 4. core utilities
do
  F.reset()
  local J = load({ AUTOSTART = false, LOG_LEVEL = 3 })
  local U = J.util
  check(U.dist2({ x = 1, z = 2 }, { x = 4, z = 6 }) == 25 and U.dist({ x = 1, z = 2 }, { x = 4, z = 6 }) == 5, "dist2 / dist")
  check(U.dist2({ x = 4, z = 6 }, { x = 1, z = 2 }) == 25, "dist2 is symmetric")
  check(U.join({ "a", "b" }) == "a, b" and U.join({ "a", "b" }, "-") == "a-b", "join: default separator")
  local k = U.keys({ b = 1, a = 1, c = 1, [2] = 1 })
  check(table.concat(k, ",") == "2,a,b,c", "keys sorted (" .. table.concat(k, ",") .. ")")
  check(U.alive(nil) == false and U.alive({}) == false and U.alive({ isExist = function() return 1 end }) == false
    and U.alive({ isExist = function() return true end }) == true, "alive: only isExist() == true")
  check(J.fmtTime(3725) == "01:02:05" and J.fmtTime(nil) == "00:00:00" and J.fmtTime(59.9) == "00:00:59", "fmtTime")
  J.debug("t", "debug line")
  check(F.logContains("[t] debug line"), "LOG_LEVEL 3 shows debug lines")
  -- scheduled jobs: a job that returns false stops
  local calls = 0
  local job = J.every("t.job", 1, function() calls = calls + 1; if calls == 3 then return false end end, 0)
  check(job and job.tag == "t.job", "every returns the job")
  for t = 0.5, 10, 0.5 do J._tick() ; F.time = t end
  check(calls == 3 and job.on == false, "a job returning false stops (" .. calls .. " calls)")
  -- errors: traceback with debug, plain message without
  J.safe("t.err1", function() error("boom one") end)
  check(F.logContains("boom one") and F.logContains("stack traceback"), "an error is logged with its traceback")
  local d = debug
  debug = nil
  J.safe("t.err2", function() error("boom two") end)
  debug = d
  local plain = false
  for _, l in ipairs(F.log) do if l:find("boom two", 1, true) and not l:find("traceback", 1, true) then plain = true end end
  check(plain, "without the debug library the message alone")
  -- scheduler and events start once
  local before = F.timers and #F.timers or 0
  J.startScheduler(); J.startScheduler()
  local after = F.timers and #F.timers or 0
  check(after - before == 1, "the scheduler starts once (" .. (after - before) .. " timers)")
  check(F.timers[#F.timers].at == F.time + 0.5, "the first scheduler tick is half a second out")
  local hits = 0
  J.on(world.event.S_EVENT_BIRTH, "t.birth", function() hits = hits + 1 end)
  J.startEvents(); J.startEvents()
  F.fire({ id = world.event.S_EVENT_BIRTH })
  check(hits == 1, "one event handler however often startEvents is called (" .. hits .. ")")
end
do
  -- no DCS clock: now() is 0
  F.reset()
  local g = timer.getTime
  timer.getTime = nil
  local J = load({ AUTOSTART = false })
  timer.getTime = g
  check(J.now() == 0, "without timer.getTime the clock reads 0")
end

print(string.format("test_gaps_setup_core: %d passed, %d failed", passed, failed))
if failed > 0 then os.exit(1) end
