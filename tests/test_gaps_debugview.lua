-- Check-mode F10 view (janus_debugview): what is drawn, in which colour, and when. The full mutation gate of
-- 2026-10-17 found it untested (42 survivors).
local F = dofile("tests/fake_dcs.lua")
local JANUS_FILE = arg and arg[1] or "dist/janus.lua"

local passed, failed = 0, 0
local function check(cond, msg)
  if cond then passed = passed + 1 else failed = failed + 1; print("  FAIL: " .. msg) end
end
local function load(settings)
  JANUS_SETTINGS = settings
  assert(loadfile(JANUS_FILE))()
  return JANUS
end
local function sameColor(a, b)
  if not (a and b) then return false end
  for i = 1, 4 do if math.abs(a[i] - b[i]) > 1e-9 then return false end end
  return true
end
local function marksOf(kind, textPart)
  local out = {}
  for id, m in pairs(F.markArgs) do
    if F.marks[id] and m.kind == kind and (not textPart or (m.text and m.text:find(textPart, 1, true))) then out[#out + 1] = m end
  end
  return out
end
local GREEN, ORANGE, YELLOW, GREY, BLUE = { 0.1, 0.8, 0.1, 1 }, { 1, 0.6, 0, 1 }, { 1, 1, 0, 1 }, { 0.5, 0.5, 0.5, 1 }, { 0.3, 0.6, 1, 0.8 }
local NOFILL = { 0, 0, 0, 0 }

-- ---------------------------------------------------------------- 1. off unless CHECK_MODE
do
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = 0 } } }
  load()
  F.run(40)
  check(next(F.markArgs) == nil, "no drawing without CHECK_MODE")
end

-- ---------------------------------------------------------------- 2. what is drawn
do
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = 0 } } }
  F.addGroup{ name = "EW Big", units = { { type = "55G6 EWR", x = 20000, z = 3000 } } }       -- 400 km: drawn at 150 km
  F.addGroup{ name = "EW Dog", units = { { type = "Dog Ear radar", x = 25000, z = 3000 } } }  -- 35 km
  F.addGroup{ name = "SAM K ACE", units = { { type = "Kub 1S91 str", x = 30000, z = 5000 }, { type = "Kub 2P25 ln", x = 30200, z = 5000 } } }
  F.addGroup{ name = "SAM Far", units = { { type = "Kub 1S91 str", x = 400000, z = 0 }, { type = "Kub 2P25 ln", x = 400200, z = 0 } } }
  local J = load({ CHECK_MODE = true })
  F.run(3)
  local circ = marksOf("circle")
  local byR = {}
  for _, c in ipairs(circ) do byR[c.r] = c end
  check(byR[150000] and byR[35000] and byR[24000], "range rings: EW capped at 150 km, short EW at its range, SAM at its reach")
  local k
  for _, c in ipairs(circ) do if c.p.x == 30000 then k = c end end
  check(k and k.c == -1 and k.line == 2 and k.ro == true and sameColor(k.fill, NOFILL), "rings: all coalitions, line 2, read-only, no fill")
  check(k and k.p.x == 30000 and k.p.z == 5000, "ring centred on the site")
  check(k and sameColor(k.color, GREEN), "a linked site is green")
  local t = marksOf("text", "SAM K ACE [BATTERY ACE] linked")
  check(#t == 1 and t[1].size == 12 and t[1].ro == true and t[1].c == -1 and sameColor(t[1].color, GREEN), "label: name, kind, tier, state")
  local far = marksOf("text", "SAM Far [BATTERY REG] unlinked")
  check(#far == 1 and sameColor(far[1].color, YELLOW), "an unlinked site is yellow")
  local lines = marksOf("line")
  local toCmd = 0
  for _, l in ipairs(lines) do
    if l.b.x == 0 and l.b.z == 0 and l.c == -1 and l.line == 3 and l.ro == true and sameColor(l.color, BLUE) then toCmd = toCmd + 1 end
  end
  check(toCmd == 3, "a blue link line from each linked site to its command post (" .. toCmd .. ")")
  check(#marksOf("text", "CMD Post [C2 REG] linked") == 1, "the command post is labelled")
  local cmdLines = 0
  for _, l in ipairs(lines) do if l.a.x == 0 and l.a.z == 0 then cmdLines = cmdLines + 1 end end
  check(cmdLines == 0, "no line from the command post to itself")
  local ids = {}
  for id in pairs(F.markArgs) do ids[#ids + 1] = id end
  table.sort(ids)
  check(ids[1] == 910001, "mark ids start above 910000 (" .. tostring(ids[1]) .. ")")

  -- redraw on a topology change: the old marks go, the state colours follow
  F.groups["SAM K ACE"].units[1].alive = false
  F.groups["SAM K ACE"].units[2].alive = false
  F.fire({ id = world.event.S_EVENT_DEAD, initiator = F.groups["SAM K ACE"].units[1] })
  F.run(12)
  local off = marksOf("text", "SAM K ACE [BATTERY ACE] offline")
  check(#off == 1 and sameColor(off[1].color, GREY), "a destroyed site is redrawn grey")
  check(#marksOf("text", "SAM K ACE [BATTERY ACE] linked") == 0, "its old label is removed")
  -- autonomous: command lost, after the crew's delay (ACE 60 s in SOVIET_PVO_1985)
  F.groups["CMD Post"].units[1].alive = false
  F.fire({ id = world.event.S_EVENT_DEAD, initiator = F.groups["CMD Post"].units[1] })
  F.run(300)
  local au = marksOf("text", "EW Dog [EW REG] autonomous")
  check(#au == 1 and sameColor(au[1].color, ORANGE), "an autonomous site is orange (redrawn every 30 s)")
end

-- ---------------------------------------------------------------- 3. no drawing API: nothing drawn, no error
do
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11", x = 0, z = 0 } } }
  local keep = trigger.action.lineToAll
  trigger.action.lineToAll = nil
  load({ CHECK_MODE = true })
  F.run(3)
  trigger.action.lineToAll = keep
  check(next(F.markArgs) == nil and not F.logContains("ERROR JANUS"), "an old DCS without the drawing calls: nothing drawn")
end

print(string.format("test_gaps_debugview: %d passed, %d failed", passed, failed))
if failed > 0 then os.exit(1) end
