-- EMCON and track picture: checks for paths the full mutation gate of 2026-10-17 found untested (policy tags,
-- restart times, EW coverage geometry, rotating EW, cued without WTA, periodic own-track hold, minimum on-time,
-- alarm state, track TTL / budget / velocity / declaration / coalition filter / nearest).
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
local function bandit(name, x, z, alt, coa)
  local g = F.addGroup{ name = name, coalition = coa or BLUE, category = AIR, units = { { type = "F-16C_50", x = x, z = z, alt = alt or 6000 } } }
  return g.units[1]
end
-- first time a group's emission switched to `on` at or after t0 (nil: never)
local function switchedAt(name, on, t0)
  for _, e in ipairs(F.emissionLog) do
    if e.group == name and e.on == on and e.t >= t0 then return e.t end
  end
  return nil
end
local function sa6(name, x, z) F.addGroup{ name = name, units = { { type = "Kub 1S91 str", x = x, z = z }, { type = "Kub 2P25 ln", x = x + 200, z = z } } } end
local function cmd() F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = 0 } } } end

-- ---------------------------------------------------------------- 1. policy tags, unknown tag, E.want / E.set edges
do
  F.reset()
  cmd()
  for i, p in ipairs({ "always", "dark", "cued", "periodic", "rotating" }) do sa6("SAM T" .. i .. " [emcon:" .. p .. "]", 1000 * i, 0) end
  sa6("SAM T9 [emcon:bogus]", 9000, 0)
  F.addGroup{ name = "EW N", units = { { type = "55G6 EWR", x = 20000, z = 0 } } }
  local J = load()
  F.run(3)
  for i, p in ipairs({ "always", "dark", "cued", "periodic", "rotating" }) do
    check(J.emcon.policyFor(node("SAM T" .. i .. " [emcon:" .. p .. "]")) == p, "tag [emcon:" .. p .. "] is a policy")
  end
  check(J.emcon.policyFor(node("SAM T9 [emcon:bogus]")) == "cued", "an unknown tag is ignored (doctrine policy)")
  local w, why = J.emcon.want(node("SAM T1 [emcon:always]"), "nonsense", F.time)
  check(w == true and why == "unknown policy", "E.want with an unknown policy: up, said so")
  check(J.emcon.set("nobody", "dark") == false and J.emcon.set("SAM T1 [emcon:always]", "dark") == true, "E.set: false for an unknown site")
  check(F.emitting("SAM T1 [emcon:always]") and not F.emitting("SAM T2 [emcon:dark]"), "always up, dark down")
  check(count("SAM T2 [emcon:dark] OFF") == 0 and count("SAM T3 [emcon:cued] OFF") == 0, "starting dark is not logged as going OFF")
  check(count("SAM T1 [emcon:always] ON (always)") == 1, "starting up is logged")
end

-- ---------------------------------------------------------------- 2. every managed kind obeys a dark tag; alarm state
do
  F.reset()
  cmd()
  F.addGroup{ name = "EW D [emcon:dark]", units = { { type = "55G6 EWR", x = 20000, z = 0 } } }
  sa6("SAM D [emcon:dark]", 30000, 0)
  F.addGroup{ name = "PD D [emcon:dark]", units = { { type = "Tor 9A331", x = 31000, z = 0 } } }
  F.addGroup{ name = "AAA D [emcon:dark]", units = { { type = "SON_9", x = 32000, z = 0 }, { type = "KS-19", x = 32100, z = 0 } } }
  F.addGroup{ name = "SHIP D [emcon:dark]", units = { { type = "MOSCOW", x = 33000, z = 0 } } }
  F.addGroup{ name = "CMD R [emcon:dark]", units = { { type = "S-300PS 54K6 cp", x = 1000, z = 0 } } }
  F.addGroup{ name = "AAA ZU", units = { { type = "ZU-23 Emplacement", x = 34000, z = 0 } } }
  local J = load()
  F.run(3)
  for _, nm in ipairs({ "EW D [emcon:dark]", "SAM D [emcon:dark]", "PD D [emcon:dark]", "AAA D [emcon:dark]", "SHIP D [emcon:dark]" }) do
    check(F.groups[nm].emission == false, nm .. ": managed, held dark")
  end
  local RED_ALARM = AI.Option.Ground.val.ALARM_STATE.RED
  local function alarm(nm) return F.groups[nm]:getController().options[AI.Option.Ground.id.ALARM_STATE] end
  check(alarm("AAA ZU") == RED_ALARM, "guns without a radar still get alarm state RED")
  check(alarm("SAM D [emcon:dark]") == RED_ALARM, "radar sites get alarm state RED")
  F.spawn{ name = "SAM Late", units = { { type = "Kub 1S91 str", x = 40000, z = 0 }, { type = "Kub 2P25 ln", x = 40200, z = 0 } } }
  F.run(8)
  check(node("SAM Late") and alarm("SAM Late") == RED_ALARM, "a late group gets alarm state RED too")
  check(J.net.dirty == false or J.net.dirty == true, "network state readable")
end

-- ---------------------------------------------------------------- 3. restart time: per range class and per type
do
  local function restartOf(group, units)
    F.reset()
    cmd()
    F.addGroup{ name = group, units = units }
    local J = load()
    F.run(2)                                      -- started: the site's tags are live now
    J.emcon.set(group, "always")
    F.run(5)
    J.emcon.set(group, "dark")
    F.run(10)
    local off = switchedAt(group, false, 5)
    J.emcon.set(group, "always")
    F.run(60)
    local on = switchedAt(group, true, 10)
    return off and on and (on - off)
  end
  local mr = restartOf("SAM K", { { type = "Kub 1S91 str", x = 0, z = 5000 }, { type = "Kub 2P25 ln", x = 200, z = 5000 } })
  check(mr and mr >= 8 and mr <= 9, "SA-6 (MR): restart 8 s (" .. tostring(mr) .. ")")
  local sa2 = restartOf("SAM S2", { { type = "SNR_75V", x = 0, z = 5000 }, { type = "p-19 s-125 sr", x = 100, z = 5000 }, { type = "S_75M_Volhov", x = 200, z = 5000 } })
  check(sa2 and sa2 >= 10 and sa2 <= 11, "SA-2 Fan Song: restartByType 10 s (" .. tostring(sa2) .. ")")
  local s5 = restartOf("SAM S5", { { type = "RPC_5N62V", x = 0, z = 5000 }, { type = "P14_SR", x = 100, z = 5000 }, { type = "S-200_Launcher", x = 200, z = 5000 } })
  check(s5 and s5 >= 25 and s5 <= 26, "SA-5 Square Pair: restartByType 25 s (" .. tostring(s5) .. ")")
  local sr = restartOf("PD Tor", { { type = "Tor 9A331", x = 0, z = 5000 } })
  check(sr and sr >= 5 and sr <= 6, "Tor (SR): restart 5 s (" .. tostring(sr) .. ")")
  local lr = restartOf("SAM S10", { { type = "S-300PS 40B6M tr", x = 0, z = 5000 }, { type = "S-300PS 5P85C ln", x = 200, z = 5000 } })
  check(lr and lr >= 10 and lr <= 11, "SA-10 (LR): restart 10 s (" .. tostring(lr) .. ")")
  local none = restartOf("EW Dog", { { type = "Dog Ear radar", x = 0, z = 5000 } })
  check(none and none >= 5 and none <= 6, "no range class: restart 5 s (" .. tostring(none) .. ")")
end

-- ---------------------------------------------------------------- 4. EW cover: geometry, network and voice
do
  F.reset()
  cmd()
  F.addGroup{ name = "EW Dog", units = { { type = "Dog Ear radar", x = 10000, z = 20000 } } }   -- 35 km detection
  sa6("SAM In", 20000, 45000)        -- 26.9 km from the EW (10 km north, 25 km east)
  sa6("SAM Out", 10000, 60000)       -- 40 km
  local J = load()
  F.run(5)
  check(node("SAM In").covered and node("SAM In").coverVia == "net", "inside the EW's range: network cover")
  check(not node("SAM Out").covered, "outside it: no cover")
  F.killGroup(F.groups["CMD Post"])
  F.run(30)
  check(node("SAM In").coverVia == "voice" and F.logContains("SAM In under voice cover from EW Dog"), "command lost: voice cover from the EW in reach")
  check(not node("SAM Out").covered, "still none out of reach")
end

-- ---------------------------------------------------------------- 5. rotating EW
do
  F.reset()
  cmd()
  F.addGroup{ name = "EW R1 [emcon:rotating]", units = { { type = "55G6 EWR", x = 20000, z = 0 } } }
  F.addGroup{ name = "EW R2 [emcon:rotating]", units = { { type = "55G6 EWR", x = 20000, z = 20000 } } }
  load()
  F.run(10)
  local a, b = F.emitting("EW R1 [emcon:rotating]"), F.emitting("EW R2 [emcon:rotating]")
  check(a and not b, "two rotating EWs, share 0.5: the first is up in the first period")
  F.run(130)
  a, b = F.emitting("EW R1 [emcon:rotating]"), F.emitting("EW R2 [emcon:rotating]")
  check(b and not a, "next period: the other one")
  F.run(250)
  check(F.emitting("EW R1 [emcon:rotating]") and not F.emitting("EW R2 [emcon:rotating]"), "and back")
  F.reset()
  cmd()
  for i = 1, 3 do F.addGroup{ name = "EW Q" .. i .. " [emcon:rotating]", units = { { type = "55G6 EWR", x = 20000, z = 10000 * i } } } end
  load()
  F.run(10)
  local up = 0
  for i = 1, 3 do if F.emitting("EW Q" .. i .. " [emcon:rotating]") then up = up + 1 end end
  check(up == 2, "three rotating EWs: two up at once (" .. up .. ")")
  F.killGroup(F.groups["EW Q2 [emcon:rotating]"])
  F.run(30)
  up = 0
  for i = 1, 3 do if F.emitting("EW Q" .. i .. " [emcon:rotating]") then up = up + 1 end end
  check(up == 1 and not F.emitting("EW Q2 [emcon:rotating]"), "a dead one leaves the rotation: one of the two left is up")
  F.reset()
  cmd()
  F.addGroup{ name = "EW Solo [emcon:rotating]", units = { { type = "55G6 EWR", x = 20000, z = 0 } } }
  load()
  F.run(10)
  check(F.emitting("EW Solo [emcon:rotating]"), "a lone rotating EW is always up")
  F.run(140)
  check(F.emitting("EW Solo [emcon:rotating]"), "... in every period")
end

-- ---------------------------------------------------------------- 6. cued without WTA: delay and reason
do
  F.reset()
  cmd()
  F.addGroup{ name = "EW N", units = { { type = "55G6 EWR", x = 20000, z = 0 } } }
  sa6("SAM K", 50000, 0)
  local b = bandit("Viper 1", 68000, 0)            -- 18 km: inside 0.8 x 24 km
  load({ RED_DOCTRINE = { base = "SOVIET_PVO_1985", wta = { enabled = false } } })
  F.sees["EW N"] = { b }
  F.run(60)
  check(F.emitting("SAM K") and F.logContains("SAM K ON (cued, track 18 km)"), "no WTA: cued by the nearest track, reason with its range")
  local first = switchedAt("SAM K", true, 0)
  local plot
  for _, l in ipairs(F.log) do if l:find("SAM K ON", 1, true) then plot = l end end
  check(first and first >= 6, "not before the REG cue delay (" .. tostring(first) .. ")")
end

-- ---------------------------------------------------------------- 7. minimum on-time
do
  F.reset()
  cmd()
  F.addGroup{ name = "EW N", units = { { type = "55G6 EWR", x = 20000, z = 0 } } }
  sa6("SAM K", 50000, 0)
  local b = bandit("Viper 1", 68000, 0)
  load({ RED_DOCTRINE = { base = "SOVIET_PVO_1985", cueHold = 0, minOn = 40 } })
  F.sees["EW N"] = { b }
  local t = 0
  while not (JANUS.net and JANUS.net.nodes["SAM K"] and JANUS.net.nodes["SAM K"].emcon.on) and t < 60 do t = t + 1; F.run(t) end
  local on = switchedAt("SAM K", true, 0)
  check(on ~= nil, "up on the cue")
  F.move(b, 400000, 0)                              -- the cue goes at the next EW poll
  F.run(on + 30)
  check(F.emitting("SAM K"), "cue gone, no cue hold: still up inside minOn (40 s)")
  F.run(on + 55)
  check(not F.emitting("SAM K"), "down after minOn")
end

-- ---------------------------------------------------------------- 8. periodic: own track holds it up; stagger from the name
do
  F.reset()
  cmd()
  sa6("SAM P", 50000, 0)                            -- no EW: autonomous periodic (SOVIET 15 s on / 60 s off)
  local b = bandit("Viper 1", 65000, 0)             -- 15 km: its own radar holds it
  local J = load()
  F.run(3)
  local h = 0
  local nm = "SAM P"
  for i = 1, #nm do h = (h * 31 + string.byte(nm, i)) % 100003 end
  local p = node("SAM P")
  F.run(80)
  check(p.emcon.phase == h % 75, "stagger phase from the name hash (" .. tostring(p.emcon.phase) .. " vs " .. (h % 75) .. ")")
  F.sees["SAM P"] = { b }
  local on = switchedAt("SAM P", true, 0)
  F.run(250)
  local offAfter = switchedAt("SAM P", false, (on or 0) + 1)
  check(on ~= nil, "periodic site came up")
  local lastOn = switchedAt("SAM P", true, 85)
  -- once its own radar holds the target it stays up: no OFF after it first saw the target while up
  local stayed = true
  for _, e in ipairs(F.emissionLog) do
    if e.group == "SAM P" and e.on == false and e.t > 160 then stayed = false end
  end
  check(stayed and F.emitting("SAM P"), "holding its own track keeps it up past the periodic window")
  F.move(b, 120000, 0)                              -- 70 km: beyond its reach
  F.run(400)
  local wentOff = false
  for _, e in ipairs(F.emissionLog) do if e.group == "SAM P" and e.on == false and e.t > 250 then wentOff = true end end
  check(wentOff, "target out of reach: back to the periodic cycle")
end

-- ---------------------------------------------------------------- 9. tracks: budget, cursor, TTL, velocity, declared, filter
do
  F.reset()
  cmd()
  for i = 1, 10 do F.addGroup{ name = "EW B" .. i, units = { { type = "55G6 EWR", x = 20000, z = 10000 * i } } } end
  local J = load()
  local before = J.tracks.stats.polls
  local t = 0
  while J.tracks.stats.polls == before and t < 10 do t = t + 0.5; F.run(t) end
  check(J.tracks.stats.polls - before == 6, "budget: 6 sensors polled in the first tick (" .. (J.tracks.stats.polls - before) .. ")")
  local polled, list = 0, J.net.list
  for i = 1, #list do if list[i].lastPoll then polled = polled + 1 end end
  check(polled == 6, "six sensors have a poll time")
  local firstSix = true
  local seen = 0
  for i = 1, #list do
    if list[i].hasRadar then
      seen = seen + 1
      if seen <= 6 and not list[i].lastPoll then firstSix = false end
    end
  end
  check(firstSix, "the cursor starts at the start of the list")
end
do
  F.reset()
  cmd()
  F.addGroup{ name = "EW N", units = { { type = "55G6 EWR", x = 20000, z = 0 } } }
  F.addGroup{ name = "EW Dark [emcon:dark]", units = { { type = "55G6 EWR", x = 20000, z = 30000 } } }
  local b = bandit("Viper 1", 150000, 0)
  local own = bandit("Flanker 1", 150000, 5000, 6000, RED)
  local neutral = bandit("Cessna", 150000, 9000, 1000, 0)
  local truck = F.addGroup{ name = "Convoy", coalition = BLUE, units = { { type = "M 818", x = 150000, z = 12000 } } }.units[1]
  local J = load({ RED_DOCTRINE = { base = "SOVIET_PVO_1985", idTime = { GRN = 90, REG = 90, VET = 90, ACE = 90 } } })
  F.sees["EW N"] = { b, own, neutral, truck }
  F.sees["EW Dark [emcon:dark]"] = { b }
  F.run(2)
  local n = node("EW N")
  local got = J.tracks.poll(n, F.time)
  check(got == 1, "poll counts only hostile aircraft (" .. tostring(got) .. "): not own, neutral or ground units")
  check(next(node("EW Dark [emcon:dark]").localTracks or {}) == nil, "a dark radar's detections are ignored")
  local polls = J.tracks.stats.polls
  J.tracks.poll(n, F.time)
  check(J.tracks.stats.polls == polls + 1, "every poll is counted")
  local tr = J.tracks.list(J.net.networks["red/main"].tracks)[1]
  check(tr and not tr.declared, "a new track is not declared hostile")
  for t = 3, 12 do F.move(b, 150000 - 250 * (t - 2), 0); F.run(t) end   -- 250 m/s south
  tr = J.tracks.list(J.net.networks["red/main"].tracks)[1]
  check(tr and tr.vel and tr.vel.x < 0 and math.abs(tr.vel.z) < 1, "velocity points the way the target moved")
  F.run(85)
  check(not tr.declared, "not yet declared before idTime (90 s)")
  F.run(100)
  check(tr.declared and tr.declBy and tr.declBy:find("held", 1, true), "declared hostile after idTime of continuous track")
  -- TTL: the EW stops seeing it; the track lingers up to TTL, then is dropped
  F.sees["EW N"] = {}
  F.run(115)
  check(next(J.net.networks["red/main"].tracks) ~= nil, "kept for a while after the last plot")
  F.run(135)
  check(next(J.net.networks["red/main"].tracks) == nil, "dropped once older than TTL (20 s)")
  -- a destroyed aircraft is dropped at once
  F.sees["EW N"] = { b }
  F.run(145)
  check(next(J.net.networks["red/main"].tracks) ~= nil, "re-acquired")
  F.kill(b)
  F.sees["EW N"] = {}
  F.run(148)
  check(next(J.net.networks["red/main"].tracks) == nil, "a dead aircraft's track goes before the TTL")
  F.killGroup(F.groups["EW N"])
  check(J.tracks.poll(n, F.time) == 0, "polling a dead group finds nothing")
end
do
  -- nearest: off-axis geometry, inclusive range
  F.reset()
  cmd()
  local J = load()
  F.run(2)
  local A = { pos = { x = 12000, y = 0, z = 10000 }, num = 2 }
  local B = { pos = { x = 10000, y = 0, z = 7000 }, num = 1 }
  local nd = { pos = { x = 10000, y = 0, z = 10000 }, linked = false, localTracks = { a = A, b = B } }
  local best, d = J.tracks.nearest(nd, 5000)
  check(best == A and math.abs(d - 2000) < 0.01, "nearest: the closer track (2 km, not 3 km)")
  best = J.tracks.nearest(nd, 2000)
  check(best == A, "range is inclusive")
  check(J.tracks.nearest(nd, 1999) == nil, "nothing inside 1999 m")
  local l = J.tracks.list({ x = A, y = B })
  check(l[1] == B and l[2] == A, "list: by track number")
  local pic = {}
  local unit = bandit("Viper 9", 5000, 5000)
  local stored = J.tracks.store(pic, unit, { x = 5000, y = 6000, z = 5000 }, 3, { name = "EW X" }, "fixed-wing", nil)
  check(stored and stored.num and pic[stored.id] == stored, "store returns the track it keeps")
end

-- ---------------------------------------------------------------- 10. more EMCON edges
do
  -- the rotation is judged by the EMCON state itself (a nil from the policy must never read as "on")
  F.reset()
  cmd()
  F.addGroup{ name = "EW Solo [emcon:rotating]", units = { { type = "55G6 EWR", x = 20000, z = 0 } } }
  load()
  F.run(10)
  check(node("EW Solo [emcon:rotating]").emcon.on == true and F.groups["EW Solo [emcon:rotating]"].emission == true,
    "a lone rotating EW is switched on (true, not nil)")
  -- an EW that is alive but lost its radar leaves the rotation
  F.reset()
  cmd()
  F.addGroup{ name = "EW A [emcon:rotating]", units = { { type = "55G6 EWR", x = 20000, z = 0 } } }
  local g = F.addGroup{ name = "EW B [emcon:rotating]", units = { { type = "55G6 EWR", x = 20000, z = 20000 }, { type = "generator_5i57", x = 20100, z = 20000 } } }
  load()
  F.run(10)
  F.kill(g.units[1])                                -- radar gone, the generator lives: alive, not working
  F.run(140)
  check(node("EW B [emcon:rotating]").alive and not node("EW B [emcon:rotating]").working, "EW B alive but not working")
  check(node("EW A [emcon:rotating]").emcon.on == true, "the other rotating EW stays up in every period")
  F.run(260)
  check(node("EW A [emcon:rotating]").emcon.on == true, "... including the next one")
end
do
  -- a periodic site is held up only by its own radar's tracks, not by the network picture
  F.reset()
  cmd()
  sa6("SAM P", 50000, 0)
  F.addGroup{ name = "PD Tor [emcon:always]", units = { { type = "Tor 9A331", x = 52000, z = 0 } } }
  local b = bandit("Viper 1", 60000, 0)
  load()
  F.sees["PD Tor [emcon:always]"] = { b }
  F.run(250)
  local offs = 0
  for _, e in ipairs(F.emissionLog) do if e.group == "SAM P" and e.on == false and e.t > 20 then offs = offs + 1 end end
  check(offs >= 2, "the Tor's track does not hold the periodic SA-6 up (" .. offs .. " OFF switches)")
end
do
  -- [emcon:cued] on an EW (doctrine: always), and a command post with a radar is managed too
  F.reset()
  cmd()
  F.addGroup{ name = "EW Q [emcon:cued]", units = { { type = "55G6 EWR", x = 20000, z = 0 } } }
  F.addGroup{ name = "CMD Radar [emcon:dark]", units = { { type = "S-300PS 54K6 cp", x = 1000, z = 0 }, { type = "55G6 EWR", x = 1100, z = 0 } } }
  local J = load()
  F.run(3)
  check(J.emcon.policyFor(node("EW Q [emcon:cued]")) == "cued", "an EW can be cued by tag")
  check(F.groups["CMD Radar [emcon:dark]"].emission == false, "a command post's radar is managed")
end
do
  -- a late group is linked at once (EMCON marks the topology dirty)
  F.reset()
  cmd()
  load()
  F.run(3)
  F.spawn{ name = "SAM Late", units = { { type = "Kub 1S91 str", x = 30000, z = 0 }, { type = "Kub 2P25 ln", x = 30200, z = 0 } } }
  F.run(9)
  check(node("SAM Late") and node("SAM Late").linked and node("SAM Late").parent ~= nil, "a late group joins the topology")
end

do
  -- rotation counts only radars of the same kind: a rotating SAM does not take turns with a rotating EW
  F.reset()
  cmd()
  F.addGroup{ name = "EW Rot [emcon:rotating]", units = { { type = "55G6 EWR", x = 20000, z = 0 } } }
  sa6("SAM Rot [emcon:rotating]", 30000, 0)
  load()
  for t = 10, 250, 30 do
    F.run(t)
    check(node("EW Rot [emcon:rotating]").emcon.on == true, "the only rotating EW is always up (t=" .. t .. ")")
  end
end
do
  -- a periodic site in its off phase is not brought back by its own leftover tracks
  F.reset()
  cmd()
  sa6("SAM P", 50000, 0)
  local b = bandit("Viper 1", 62000, 0)
  local J = load()
  F.sees["SAM P"] = { b }
  F.run(100)
  local p = node("SAM P")
  check(p.emcon.on == true, "held up by its own track")
  J.emcon.set("SAM P", "dark")
  F.run(103)
  check(p.emcon.on == false, "forced dark")
  -- back to periodic at a moment in the off part of its cycle, with the leftover track still fresh
  local phase = p.emcon.phase
  local t = 104
  while ((t + phase) % 75) < 20 do t = t + 1 end
  F.run(t)
  J.emcon.set("SAM P", nil)
  F.run(t + 12)
  if ((t + 12 + phase) % 75) >= 15 then
    check(p.emcon.on == false, "off part of the cycle: leftover tracks do not bring it up")
  end
end

-- ---------------------------------------------------------------- 11. more track edges
do
  F.reset()
  cmd()
  F.addGroup{ name = "EW N", units = { { type = "55G6 EWR", x = 20000, z = 0 } } }
  local b = bandit("Viper 1", 150000, 0, 3000)
  local J = load({ RED_DOCTRINE = { base = "SOVIET_PVO_1985", idTime = { GRN = 90, REG = 90, VET = 90, ACE = 90 } } })
  F.run(50)
  F.sees["EW N"] = { b }                            -- first seen around t = 50
  for t = 51, 62 do b.alt = 3000 + 100 * (t - 50); F.run(t) end   -- climbing 100 m/s
  local tr = J.tracks.list(J.net.networks["red/main"].tracks)[1]
  check(tr and tr.vel and tr.vel.y > 50, "climb shows in the velocity")
  local first = tr and tr.first or 0
  F.run(first + 60)
  check(tr and not tr.declared, "60 s after first contact: not yet declared (idTime 90 s)")
  F.run(first + 100)
  check(tr and tr.declared, "after idTime: declared")
  local pic = {}
  for i, nm in ipairs({ 5, 3, 9, 1, 7 }) do pic["k" .. i] = { num = nm } end
  local l = J.tracks.list(pic)
  local ok = true
  for i = 2, #l do if l[i - 1].num >= l[i].num then ok = false end end
  check(ok and #l == 5, "list sorted by track number")
end

print(string.format("test_gaps_emcon_tracks: %d passed, %d failed", passed, failed))
if failed > 0 then os.exit(1) end
