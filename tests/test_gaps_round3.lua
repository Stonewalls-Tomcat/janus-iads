-- Round 3 of the full mutation gate (2026-10-17, 25 survivors): geometry that was only tested on one axis or at the
-- origin, sort orders, rotation slots, and a few guards.
local F = dofile("tests/fake_dcs.lua")
local JANUS_FILE = arg and arg[1] or "dist/janus.lua"
local BLUE, RED = coalition.side.BLUE, coalition.side.RED
local AIR = Group.Category.AIRPLANE
local ROE = AI.Option.Ground.id.ROE
local OPEN, HOLD = AI.Option.Ground.val.ROE.OPEN_FIRE, AI.Option.Ground.val.ROE.WEAPON_HOLD

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
local function count(pattern)
  local n = 0
  for _, l in ipairs(F.log) do if l:find(pattern, 1, true) then n = n + 1 end end
  return n
end
local freshReset = F.reset
F.reset = function()
  if JANUS then check(not F.logContains("ERROR JANUS"), "no Janus errors before a reset (t=" .. F.time .. ")") end
  freshReset()
end
local function roe(name)
  local g = F.groups[name]
  return g and g.controller and g.controller.options[ROE]
end
local function bandit(name, x, z, alt, acType)
  return F.addGroup{ name = name, coalition = BLUE, category = AIR,
    units = { { type = acType or "F-16C_50", x = x, z = z, alt = alt or 6000 } } }.units[1]
end
local function sa6(name, x, z)
  F.addGroup{ name = name, units = { { type = "Kub 1S91 str", x = x, z = z }, { type = "Kub 2P25 ln", x = x + 200, z = z } } }
end
local function trackOf(J, unit)
  local net = J.net.networks["red/main"]
  return net.tracks and net.tracks[unit:getID()]
end

-- ---------------------------------------------------------------- 1. flak trap away from the map origin
do
  F.reset()
  local X, Z = 40000, 30000
  F.addGroup{ name = "CMD Hanoi", units = { { type = "SKP-11", x = X, z = Z - 10000 } } }
  F.addGroup{ name = "EW Hanoi", units = { { type = "p-19 s-125 sr", x = X, z = Z + 5000 } } }
  F.addGroup{ name = "AAA S-60 East", units = { { type = "S-60_Type59_Artillery", x = X, z = Z },
    { type = "S-60_Type59_Artillery", x = X + 50, z = Z } } }
  local b = bandit("Phantom 1", X + 30000, Z, 1000, "F-4E")
  load({ RED_DOCTRINE = { base = "NVA_VIETNAM_1965_72", aaa = { mode = "trap" } } })
  F.sees["EW Hanoi"] = { b }
  F.run(3)
  check(roe("AAA S-60 East") == HOLD, "trap set")
  F.move(b, X + 2500, Z + 2500)                 -- 3.5 km off the guns, inside 0.7 x 6 km
  F.run(15)
  check(roe("AAA S-60 East") == OPEN, "a target 2.5 km north-east of guns at (40, 30) km opens the trap")
end

-- ---------------------------------------------------------------- 2. track velocity on the z axis
do
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = 0 } } }
  F.addGroup{ name = "EW Dog", units = { { type = "Dog Ear radar", x = 0, z = 1000 } } }
  local b = bandit("Viper 1", 20000, 20000)
  local J = load()
  F.sees["EW Dog"] = { b }
  F.run(6)
  local tr = trackOf(J, b)
  local t0 = tr and tr.t
  F.move(b, 20000, 21000)
  local t = F.time
  while trackOf(J, b).t == t0 and t < 30 do t = t + 0.5; F.run(t) end
  tr = trackOf(J, b)
  check(tr.vel and tr.vel.z > 0 and math.abs(tr.vel.x) < 1e-6, "moving +z: velocity +z (" .. tostring(tr.vel and tr.vel.z) .. ")")
end

-- ---------------------------------------------------------------- 3. W.pk: the lead point moves vertically too
do
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = -20000 } } }
  sa6("SAM K", 0, 0)
  local J = load()
  F.run(3)
  local n = node("SAM K")
  local env = J.wta.envelope(n)
  local tr = { pos = { x = 10000, y = env.aMax + 2000, z = 0 }, vel = { x = 0, y = -200, z = 0 } }
  check(J.wta.pk(n, tr) == 0, "above the ceiling now: Pk 0")
  check(J.wta.pk(n, tr, 20) > 0, "diving 4 km in the 20 s lead: inside the envelope, Pk > 0")
end

-- ---------------------------------------------------------------- 4. GCI: radar heads and posts off the axes
do
  F.reset()
  F.addGroup{ name = "CMD A", units = { { type = "SKP-11", x = 0, z = 0 } } }
  F.addGroup{ name = "CMD B", units = { { type = "SKP-11", x = 12000, z = 28000 } } }
  F.addGroup{ name = "EW Dog", units = { { type = "Dog Ear radar", x = 10000, z = 20000 } } }   -- 35 km radar head
  local J = load()
  F.run(3)
  local G = J.gci
  check(G.controlState(RED, { x = 60000, z = 20000 }).ground == false, "50 km east of the only head (same z): not covered")
  local cs = G.controlState(RED, { x = 20000, z = 45000 })
  check(cs.via == "CMD B" and math.abs(cs.dist - math.sqrt(8000 ^ 2 + 17000 ^ 2)) < 1, "distance to post B (" .. tostring(cs.dist) .. ")")
  -- commit requests sorted by threat, highest first
  local net = J.net.networks["red/main"]
  net.assign, net.unassigned, net.tracks = {}, {}, {}
  for i = 1, 6 do
    local tr = { id = 900 + i, num = i, threat = i * 10, pos = { x = 1000 * i, y = 5000, z = 0 }, t = F.time, class = "air" }
    net.tracks[tr.id] = tr
    net.unassigned[tr.id] = { tr = tr, reason = "out of reach" }
  end
  local cr = G.commitRequests(RED)
  local ok = #cr == 6
  for i = 2, #cr do if cr[i - 1].threat < cr[i].threat then ok = false end end
  check(ok, "commit requests: highest threat first")
end

-- ---------------------------------------------------------------- 5. WTA: the higher threat gets the only channel; reach off the axis
do
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = -20000 } } }
  F.addGroup{ name = "EW Dog", units = { { type = "Dog Ear radar", x = 0, z = 1000 } } }
  sa6("SAM K [emcon:always]", 0, 0)
  local far = bandit("Far 1", 20000, 0, 8000)
  local far2 = bandit("Far 2", 20000, 3000, 8000)
  local near = bandit("Near 1", 9000, 0, 1500)
  local J = load()
  F.sees["EW Dog"] = { far, far2, near }
  F.sees["SAM K [emcon:always]"] = { far, far2, near }
  F.run(12)
  local net = J.net.networks["red/main"]
  local tf, tn = trackOf(J, far), trackOf(J, near)
  check(tf and tn and tf.num < tn.num and tn.threat > tf.threat, "the last track is the highest threat")
  local env = J.wta.envelope(node("SAM K [emcon:always]"))
  local onNear = net.assign and net.assign[near:getID()]
  check(env.channels == 2 and onNear ~= nil and #onNear > 0, "two channels, three targets: the highest threat is engaged")
  -- a track far out along z is out of reach, not short of a free shooter
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = -20000 } } }
  F.addGroup{ name = "EW Dog", units = { { type = "Dog Ear radar", x = 0, z = 1000 } } }
  sa6("SAM K [emcon:always]", 0, 0)
  local z = bandit("North 1", 0, 33000, 6000)
  J = load()
  F.sees["EW Dog"] = { z }
  F.run(12)
  local u = J.net.networks["red/main"].unassigned
  u = u and u[z:getID()]
  check(u and u.reason == "out of reach", "33 km north of a 24 km SA-6: out of reach (" .. tostring(u and u.reason) .. ")")
end

-- ---------------------------------------------------------------- 6. rotating EW: which radar is up in which period
do
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = 0 } } }
  for i = 1, 3 do F.addGroup{ name = "EW Q" .. i .. " [emcon:rotating]", units = { { type = "55G6 EWR", x = 20000, z = 10000 * i } } } end
  load({ RED_DOCTRINE = { base = "SOVIET_PVO_1985", rotating = { share = 0.34, period = 120 } } })
  local function up()
    local s = ""
    for i = 1, 3 do if node("EW Q" .. i .. " [emcon:rotating]").emcon.on then s = s .. i end end
    return s
  end
  F.run(10)
  check(up() == "1", "period 0: Q1 (" .. up() .. ")")
  F.run(130)
  check(up() == "3", "period 1: the set shifts back one, Q3 (" .. up() .. ")")
  F.run(250)
  check(up() == "2", "period 2: Q2 (" .. up() .. ")")
end

-- ---------------------------------------------------------------- 7. events: a mission without an event API
do
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = 0 } } }
  local J = load()
  F.run(3)
  local add = world.addEventHandler
  J._eventsOn = false
  world.addEventHandler = nil
  local ok = pcall(J.startEvents)
  world.addEventHandler = add
  check(ok and not J._eventsOn, "no world.addEventHandler: startEvents returns quietly")
end

-- ---------------------------------------------------------------- 8. stats: a site that only lost units is reported
do
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = 0 }, { type = "SKP-11", x = 50, z = 0 } } }
  local J = load()
  F.run(3)
  F.groups["CMD Post"].units[2].alive = false
  J.statsMod.report("test")
  check(count("CMD Post: emitting 0.0 min, 0 shots, 0 kills, 1 units lost") == 1, "lost units alone put a site in the report")
end

-- ---------------------------------------------------------------- 9. spawn: the units' offsets are added
do
  F.reset()
  F.waterFn = function(x) return x < -100 end    -- the sea west of x = -100
  local J = load()
  local fx, fz = J.spawn.findSite({ { dx = 0, dz = 0 }, { dx = 500, dz = 0 } }, 0, 0, 0, 30, 1000)
  F.waterFn = nil
  check(fx == 0 and fz == 0, "a unit 500 m east of a centre on the coast stands on land: the centre fits (" .. tostring(fx) .. ")")
end

-- ---------------------------------------------------------------- 10. check-mode view: no ring without a reach; offline when broken
do
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = 0 } } }
  sa6("SAM K ACE", 30000, 5000)
  load({ CHECK_MODE = true })
  F.run(3)
  local ringAtCmd = false
  for _, m in pairs(F.markArgs) do if m.kind == "circle" and m.p.x == 0 and m.p.z == 0 then ringAtCmd = true end end
  check(not ringAtCmd, "a command post (no reach) gets no ring")
  F.groups["SAM K ACE"].units[1].alive = false                  -- the radar: the launcher stands, the site is broken
  F.fire({ id = world.event.S_EVENT_DEAD, initiator = F.groups["SAM K ACE"].units[1] })
  F.run(12)
  local off = 0
  for id, m in pairs(F.markArgs) do
    if F.marks[id] and m.kind == "text" and m.text and m.text:find("SAM K ACE [BATTERY ACE] offline", 1, true) then off = off + 1 end
  end
  check(node("SAM K ACE").alive and not node("SAM K ACE").working and off == 1, "alive but not working is drawn offline")
end

-- ---------------------------------------------------------------- 11. ARM along z: the estimate dead-reckons on z
-- the same shot along -x and along -z must give the same dark time (the x case is block 2 of test_arm)
do
  local function darkFor(vx, vz)
    F.reset()
    F.rnd = 0
    F.addGroup{ name = "CMD Post", units = { { type = "S-300PS 54K6 cp", x = -20000, z = -20000 } } }
    sa6("SAM SA-6 A [emcon:always]", 0, 0)
    local viper = bandit("Viper 1", 0, 200000)
    load()
    F.run(3)
    F.launch{ shooter = viper, type = "AGM_88", x = -vx * 100, y = 5000, z = -vz * 100, vx = vx, vz = vz }
    F.run(3 + 68)
    local s = node("SAM SA-6 A [emcon:always]").arm.dark
    return s and (s.untilT - s.since)
  end
  local ax, az = darkFor(-600, 0), darkFor(0, -600)
  check(ax and az and ax > 60 and math.abs(ax - az) < 0.01, "inbound along -x or -z: the same dark time (" .. tostring(ax) .. ", " .. tostring(az) .. ")")
end

-- the dark SA-10 no longer sees the missile and dead-reckons it: inbound along -z, the Tor stays forced up
do
  F.reset()
  F.rnd = 0
  F.addGroup{ name = "CMD Post", units = { { type = "S-300PS 54K6 cp", x = -20000, z = 0 } } }
  F.addGroup{ name = "SAM SA-10 Kiev [emcon:always]", units = { { type = "S-300PS 40B6M tr", x = 0, z = 0 },
    { type = "S-300PS 5P85C ln", x = 0, z = 300 } } }
  F.addGroup{ name = "PD Tor Guard [emcon:dark]", units = { { type = "Tor 9A331", x = 8000, z = 0 } } }
  local viper = bandit("Viper 1", 0, 200000)
  load()
  F.run(3)
  F.launch{ shooter = viper, type = "AGM_88", x = 0, y = 5000, z = 50000, vx = 0, vz = -600 }
  F.run(3 + 60)
  check(not F.emitting("SAM SA-10 Kiev [emcon:always]") and F.emitting("PD Tor Guard [emcon:dark]"),
    "inbound along -z: the SA-10 dark, the Tor still forced up")
end

check(not F.logContains("ERROR JANUS"), "no Janus errors")
print(string.format("test_gaps_round3: %d passed, %d failed", passed, failed))
if failed > 0 then os.exit(1) end
