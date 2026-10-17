-- GCI interface, base warning, API, names, stats and WTA edges: checks for paths the full mutation gate of
-- 2026-10-17 found untested (mostly geometry that was only ever tested on one axis).
local F = dofile("tests/fake_dcs.lua")
local JANUS_FILE = arg and arg[1] or "dist/janus.lua"
local BLUE, RED = coalition.side.BLUE, coalition.side.RED
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
local function bandit(name, x, z, alt)
  return F.addGroup{ name = name, coalition = BLUE, category = AIR, units = { { type = "F-16C_50", x = x, z = z, alt = alt or 6000 } } }.units[1]
end
local function sa6(name, x, z) F.addGroup{ name = name, units = { { type = "Kub 1S91 str", x = x, z = z }, { type = "Kub 2P25 ln", x = x + 200, z = z } } } end

-- ---------------------------------------------------------------- 1. GCI interface
do
  F.reset()
  F.addGroup{ name = "CMD A", units = { { type = "SKP-11", x = 0, z = 0 } } }
  F.addGroup{ name = "CMD B", units = { { type = "SKP-11", x = 12000, z = 28000 } } }
  F.addGroup{ name = "EW Dog", units = { { type = "Dog Ear radar", x = 10000, z = 20000 } } }   -- 35 km radar head
  local J = load()
  F.run(3)
  local G = J.gci
  local h1 = G.on("nodeLost", function() end, "k")
  local h2 = G.on("nodeLost", function() end, "k")
  check(h1 ~= nil and h1 == h2, "same key: the same handle back")
  check(G.off(123456) == false and G.off(h1) == true, "off: false for an unknown handle")
  local cs = G.controlState(RED, { x = 20000, z = 45000 })        -- 26.9 km from the head (10 km N, 25 km E)
  check(cs.ground == true and cs.via == "CMD B", "point inside the radar head, nearest post B controls (" .. tostring(cs.via) .. ")")
  check(G.controlState(RED, { x = 10000, z = 60000 }).ground == false, "40 km from the only head: no ground control")
  -- tracks sorted by number
  local list = {}
  for i = 1, 6 do list[i] = bandit("V" .. i, 100000 + 1000 * i, 7000 * i) end
  F.sees["EW Dog"] = list
  F.run(12)
  local tr = G.tracks(RED)
  local ok = #tr == 6
  for i = 2, #tr do if tr[i - 1].num >= tr[i].num then ok = false end end
  check(ok, "GCI tracks sorted by number (" .. #tr .. ")")
end

-- ---------------------------------------------------------------- 2. base warning: geometry, place names, weapon kinds
do
  F.reset()
  F.airbases = { { name = "Alpha", x = 12000, z = 20000 }, { name = "Bravo", x = 10000, z = 17000 } }
  F.addGroup{ name = "CMD Post", coalition = BLUE, units = { { type = "Patriot cp", x = 0, z = 0 } } }
  F.addGroup{ name = "PD Base", coalition = BLUE, units = { { type = "HEMTT_C-RAM_Phalanx", x = 10000, z = 20000 } } }
  local red = F.addGroup{ name = "Flanker", coalition = RED, category = AIR, units = { { type = "Su-24M", x = 60000, z = 60000 } } }.units[1]
  local J = load({ BASE_WARNING = true })
  F.run(2)
  -- outside the 12 km warning range, off both axes (9 km N, 9 km E = 12.7 km)
  F.launch{ shooter = red, type = "KAB_500", x = 19000, y = 1000, z = 29000, vx = 0, vz = 0, category = Weapon.Category.BOMB }
  F.run(5)
  check(count("INCOMING") == 0, "a weapon 12.7 km out: no warning")
  F.launch{ shooter = red, type = "KAB_500", x = 18000, y = 1000, z = 27000, vx = 0, vz = 0, category = Weapon.Category.BOMB }
  F.run(8)
  check(count("INCOMING at Alpha") == 1, "10.6 km out (8 N, 7 E): warned, named after the nearest airbase (Alpha, 2 km)")
  F.launch{ shooter = red, type = "R-77", x = 12000, y = 1000, z = 21000, vx = 0, vz = 0,
    category = Weapon.Category.MISSILE, missileCategory = Weapon.MissileCategory.AAM }
  F.launch{ shooter = red, type = "SA9M311", x = 12000, y = 1000, z = 21000, vx = 0, vz = 0,
    category = Weapon.Category.MISSILE, missileCategory = Weapon.MissileCategory.SAM }
  F.run(60)
  check(count("R-77") == 0 and count("SA9M311") == 0, "air-to-air and surface-to-air missiles are not the base's business")
  F.launch{ shooter = red, type = "Kh-29L", x = 12000, y = 1000, z = 21000, vx = 0, vz = 0,
    category = Weapon.Category.MISSILE, missileCategory = Weapon.MissileCategory.OTHER }
  F.run(70)
  check(count("Kh-29L") == 1, "an air-to-ground missile warns")
end

-- ---------------------------------------------------------------- 3. API, names, stats
do
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = 0 } } }
  local g = F.addGroup{ name = "SAM D [emcon:dark]", units = { { type = "Kub 1S91 str", x = 30000, z = 0 }, { type = "Kub 2P25 ln", x = 30200, z = 0 } } }
  local J = load({ STATS = true })
  F.run(3)
  check(J.unsubscribe(987654) == false, "unsubscribe of an unknown handle: false")
  check(J.setHold("nobody", true) == false and J.setHold("SAM D [emcon:dark]", true) == true, "setHold: false for an unknown site")
  local l = J.names.list(nil)
  check(type(l) == "table" and #l == 0, "names.list(nil): an empty list")
  check(table.concat(J.names.list(" a, b ,c "), "|") == "a|b|c", "names.list trims")
  F.launch{ shooter = g.units[2], type = "SA3M9", x = 30200, y = 100, z = 0, vx = 300, vz = 0 }
  J.statsMod.report("test")
  check(F.logContains("red SAM D [emcon:dark]: emitting 0.0 min, 1 shots, 0 kills, 0 units lost"), "stats: a site that only shot is listed")
  check(not F.logContains("red CMD Post:"), "stats: a site with nothing to report is left out")
end

-- ---------------------------------------------------------------- 4. WTA geometry: slant, lead, reach check, target choice
do
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = 0 } } }
  F.addGroup{ name = "SAM S10", units = { { type = "S-300PS 40B6M tr", x = 10000, z = 10000 }, { type = "S-300PS 5P85C ln", x = 10300, z = 10000 } } }
  local J = load()
  F.run(3)
  local n = node("SAM S10")
  local W = J.wta
  local function tr(x, z, alt, vx, vz) return { pos = { x = x, y = alt, z = z }, vel = vx and { x = vx, y = 0, z = vz } or nil } end
  -- 72 km horizontal at 26 km altitude: slant 76.5 km > 75 km reach
  check(W.pk(n, tr(10000 + 72000 * 0.6, 10000 + 72000 * 0.8, 26000), 0) == 0, "slant range counts the altitude")
  check(W.pk(n, tr(10000 + 60000 * 0.6, 10000 + 60000 * 0.8, 9000), 0) > 0, "60 km, 9 km up: in reach")
  -- 80 km out, inbound at 300 m/s along the diagonal: judged 40 s ahead it is at 68 km
  local s = 300 / math.sqrt(2)
  local far = tr(10000 + 80000 / math.sqrt(2), 10000 + 80000 / math.sqrt(2), 8000, -s, -s)
  check(W.pk(n, far, 0) == 0 and W.pk(n, far, 40) > 0, "lead: an inbound target is judged where it will be")
  local away = tr(10000 + 80000 / math.sqrt(2), 10000 + 80000 / math.sqrt(2), 8000, s, s)
  check(W.pk(n, away, 40) == 0, "lead: an outbound target is not")
  check(W.setWeapons(n.net, "bogus") == false and W.setWeapons(n.net, "tight") == true, "setWeapons: false for an unknown state")
  -- targetFor: the nearest assigned track, off both axes
  n.assigned = { tr(10000 + 3000, 10000, 5000), tr(10000, 10000 - 2500, 5000) }
  local best, d = W.targetFor(n)
  check(best == n.assigned[2] and math.abs(d - 2500) < 0.01, "targetFor: the nearest assigned track (2.5 km, not 3 km)")
  n.assigned = nil
end
do
  -- the cheap reach check before the Pk model uses true horizontal distance
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = 0 } } }
  F.addGroup{ name = "EW N", units = { { type = "55G6 EWR", x = 20000, z = 0 } } }
  F.addGroup{ name = "SAM S10", units = { { type = "S-300PS 40B6M tr", x = 10000, z = 10000 }, { type = "S-300PS 5P85C ln", x = 10300, z = 10000 } } }
  local b = bandit("Viper 1", 10000 + 30000, 10000 + 40000)   -- 50 km away (30 N, 40 E)
  load()
  F.sees["EW N"] = { b }
  F.run(20)
  check(node("SAM S10").assigned ~= nil, "a target 50 km off both axes is assigned")
  check(F.logContains("assigned to SAM S10") , "assignment logged")
end

-- ---------------------------------------------------------------- 5. ARM defence geometry
do
  F.reset()
  local J = load({ AUTOSTART = false })
  local off = J.arm._offAngle
  check(math.abs(off({ x = 0, z = 0 }, { x = 1, z = 1 }, { x = 10, z = 10 })) < 0.01, "offAngle: dead ahead on a diagonal is 0")
  check(math.abs(off({ x = 0, z = 0 }, { x = 1, z = 1 }, { x = 10, z = -10 }) - 90) < 0.01, "offAngle: square to a diagonal is 90")
  check(math.abs(off({ x = 0, z = 0 }, { x = -1, z = 0 }, { x = 10, z = 0 }) - 180) < 0.01, "offAngle: behind is 180")
end
local function armScene(extra)
  F.reset()
  F.rnd = 0
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = -20000 } } }
  sa6("SAM A [emcon:always]", 10000, 20000)
  if extra then extra() end
  local viper = bandit("Viper 1", 200000, 0)
  local J = load()
  F.run(3)
  return J, viper
end
do
  -- an ARM on a diagonal path at the SA-6 (both velocity components matter)
  local J, viper = armScene()
  local s = 600 / math.sqrt(2)
  F.launch{ shooter = viper, type = "AGM_88", x = 10000 + 30000, y = 3000, z = 20000 + 30000, vx = -s, vz = -s }
  F.run(60)
  check(count("SAM A [emcon:always] DARK for") == 1, "a diagonal ARM aimed at the site darkens it")
end
do
  -- a Tor 15 km off both axes covers the SA-6 (pdCoverRange 15 km); one 16 km away does not
  local J, viper = armScene(function()
    F.addGroup{ name = "PD Tor Near", units = { { type = "Tor 9A331", x = 10000 + 9000, z = 20000 + 12000 } } }
    F.addGroup{ name = "PD Tor Far", units = { { type = "Tor 9A331", x = 10000 - 9600, z = 20000 - 12800 } } }
  end)
  F.launch{ shooter = viper, type = "AGM_88", x = 10000 + 30000, y = 3000, z = 20000, vx = -600, vz = 0 }
  F.run(60)
  check(count("PD Tor Near ON (ARM cover)") == 1, "the Tor 15 km away comes up as ARM cover")
  check(count("PD Tor Far ON (ARM cover)") == 0, "the one 16 km away does not")
end
do
  -- an ARM high above: the slant range counts (SA-6 sees ARMs to 0.35 x 70 km = 24.5 km)
  local J, viper = armScene()
  F.launch{ shooter = viper, type = "AGM_88", x = 10000 + 12000, y = 25000, z = 20000 + 16000, vx = 1, vz = 0 }
  F.run(20)
  check(count("SAM A [emcon:always] sees ARM") == 0, "20 km out but 25 km up (32 km slant): not seen")
  armScene()
  F.launch{ shooter = JANUS and F.groups["Viper 1"].units[1], type = "AGM_88", x = 10000 + 12000, y = 1000, z = 20000 + 16000, vx = 1, vz = 0 }
  F.run(20)
  check(count("SAM A [emcon:always] sees ARM") >= 1, "20 km out, low: seen")
end
do
  -- a busy radar sees less: 10 tracks halve the chance (p 0.25 -> 0.125; roll 0.2)
  local J, viper = armScene()
  F.rnd = 0.2
  F.launch{ shooter = viper, type = "AGM_88", x = 10000 + 12000, y = 1000, z = 20000 + 16000, vx = 1, vz = 0 }
  F.run(20)
  check(count("SAM A [emcon:always] sees ARM") >= 1, "idle radar, roll 0.2 < 0.25: seen")
  J = armScene()
  local list = {}
  for i = 1, 10 do list[i] = bandit("B" .. i, 10000 + 5000 + 100 * i, 20000 + 5000) end
  F.sees["SAM A [emcon:always]"] = list
  F.run(10)
  F.rnd = 0.2
  F.launch{ shooter = F.groups["Viper 1"].units[1], type = "AGM_88", x = 10000 + 12000, y = 1000, z = 20000 + 16000, vx = 1, vz = 0 }
  F.run(30)
  check(count("SAM A [emcon:always] sees ARM") == 0, "ten tracks on the scope: roll 0.2 > 0.125, not seen")
end
do
  -- only the front emitter on the missile's line is threatened; a site 15 km behind it is not
  local J, viper = armScene(function()
    sa6("SAM Rear [emcon:always]", 10000 - 15000, 20000)
  end)
  F.launch{ shooter = viper, type = "AGM_88", x = 10000 + 30000, y = 3000, z = 20000, vx = -600, vz = 0 }
  F.run(60)
  check(count("SAM A [emcon:always] DARK for") == 1, "the front site goes dark")
  check(count("SAM Rear [emcon:always] DARK for") == 0, "the site 15 km behind it does not")
end

-- ---------------------------------------------------------------- 6. spawner: spacing layout, rotation, slope under every unit
do
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = 0 } } }
  local J = load()
  F.run(2)
  local SP = J.spawn
  local L = SP.layout(J.Presets["SA-11"])
  local tel = {}
  for _, u in ipairs(L) do if u.type == "SA-11 Buk LN 9A310M1" then tel[#tel + 1] = u end end
  local ok = #tel == 6
  for k, u in ipairs(tel) do if u.dz ~= 250 * k then ok = false end end
  check(ok, "spacing: TELARs one spacing apart to the east (250 m x k)")
  check(tel[2] and tel[2].dx - tel[1].dx == 40, "spacing: each spaced unit 40 m further north")
  -- rotation at 45 degrees, on a unit off both axes
  F.added = {}
  local name, info = J.spawnBattery("SA-11", { x = 50000, z = 50000 }, { heading = 45, label = "Rot" })
  local data = F.added[#F.added].data
  local u3 = tel[3]
  local h = math.rad(45)
  local ex = 50000 + u3.dx * math.cos(h) - u3.dz * math.sin(h)
  local ez = 50000 + u3.dx * math.sin(h) + u3.dz * math.cos(h)
  local found = false
  for _, u in ipairs(data.units) do
    if u.type == "SA-11 Buk LN 9A310M1" and math.abs(u.x - ex) < 0.01 and math.abs(u.y - ez) < 0.01 then found = true end
  end
  check(name ~= nil and found, "heading 45: a unit off both axes is turned correctly")
  check(data.units[1] and F.added[#F.added].country == country.id.RUSSIA, "no coalition given: red (Russia)")
  -- steep ground east of z = 60100: the TELARs east of the centre would stand on it, so the site moves
  F.heightFn = function(x, z) if z > 60100 then return (z - 60100) * 0.6 else return 0 end end
  local nm, inf = J.spawnBattery("SA-11", { x = 60000, z = 60000 }, { label = "Slope" })
  check(nm ~= nil and inf.z < 60000 - 1000, "every unit's own ground is checked: the site moved off the slope (z " .. tostring(inf and inf.z) .. ")")
  local d = inf and math.sqrt((inf.x - 60000) ^ 2 + (inf.z - 60000) ^ 2)
  check(d and F.logContains(string.format("%.0f m from the point asked", d)), "the log gives the true distance moved")
  F.heightFn = nil
end

print(string.format("test_gaps_misc: %d passed, %d failed", passed, failed))
if failed > 0 then os.exit(1) end
