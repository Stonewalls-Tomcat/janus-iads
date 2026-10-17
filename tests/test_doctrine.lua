-- Doctrine profiles and the reach table against the owner-approved snapshot (tests/doctrine_snapshot.lua).
-- Every value in every profile is a decision (owner reviews 2026-10-01, 2026-10-17): this harness makes any change
-- deliberate. The full mutation gate of 2026-10-17 found 136 doctrine values no test noticed. Also checks that
-- derive() copies (profiles never share tables) and that getDoctrine resolves names, custom tables and unknowns.
local F = dofile("tests/fake_dcs.lua")
local JANUS_FILE = arg and arg[1] or "dist/janus.lua"

local passed, failed = 0, 0
local function check(cond, msg)
  if cond then passed = passed + 1 else failed = failed + 1; print("  FAIL: " .. msg) end
end

F.reset()
JANUS_SETTINGS = nil
assert(loadfile(JANUS_FILE))()
local J = JANUS
local S = dofile("tests/doctrine_snapshot.lua")

-- deep comparison both ways; collects every differing path
local diffs = {}
local function cmp(a, b, path)
  if type(a) ~= type(b) then diffs[#diffs + 1] = path .. ": " .. tostring(a) .. " vs snapshot " .. tostring(b); return end
  if type(a) ~= "table" then
    if a ~= b then diffs[#diffs + 1] = path .. ": " .. tostring(a) .. " vs snapshot " .. tostring(b) end
    return
  end
  for k, v in pairs(b) do cmp(a[k], v, path .. "." .. tostring(k)) end
  for k, v in pairs(a) do
    if b[k] == nil then diffs[#diffs + 1] = path .. "." .. tostring(k) .. ": " .. tostring(v) .. " not in the snapshot" end
  end
end

for name, prof in pairs(S.Doctrines) do
  diffs = {}
  cmp(J.Doctrines[name], prof, name)
  check(#diffs == 0, "doctrine " .. name .. " matches the snapshot" .. (#diffs > 0 and (": " .. table.concat(diffs, "; ")) or ""))
end
for name in pairs(J.Doctrines) do check(S.Doctrines[name] ~= nil, "doctrine " .. name .. " is in the snapshot") end
diffs = {}
cmp(J.Reach, S.Reach, "Reach")
check(#diffs == 0, "reach table matches the snapshot" .. (#diffs > 0 and (": " .. table.concat(diffs, "; ")) or ""))
check(J.REACH_LOW == S.REACH_LOW and J.REACH_HIGH == S.REACH_HIGH, "reach height band matches the snapshot")

-- derive copies: changing one profile's table never reaches another or the base
local a, b = J.Doctrines.SOVIET_PVO_1985, J.Doctrines.RUSSIA_MODERN
check(a.arm ~= b.arm and a.cueDelay ~= b.cueDelay and a.emcon ~= b.emcon, "profiles do not share tables")
local keep = b.cueDelay.REG
a.cueDelay.REG = -1
check(b.cueDelay.REG == keep and J.Doctrines.US_MODERN.cueDelay.REG ~= -1, "a change to one profile stays in it")
a.cueDelay.REG = S.Doctrines.SOVIET_PVO_1985.cueDelay.REG

-- getDoctrine: by name, custom table on a named base (shallow merge per sub-table), unknown name
check(J.getDoctrine("NATO_COLDWAR") == J.Doctrines.NATO_COLDWAR, "by name: the profile itself")
local c = J.getDoctrine({ base = "US_MODERN", ambush = 0.5, arm = { maxDark = 33 } })
check(c.ambush == 0.5 and c.arm.maxDark == 33 and c.arm.minDark == J.Doctrines.US_MODERN.arm.minDark
  and c.cueSource == "any" and c.name == "custom:US_MODERN", "custom table: own values over the base, the rest kept")
check(J.Doctrines.US_MODERN.ambush == S.Doctrines.US_MODERN.ambush and J.Doctrines.US_MODERN.arm.maxDark == S.Doctrines.US_MODERN.arm.maxDark,
  "a custom table never changes its base")
local named = J.getDoctrine({ name = "MINE", cueDelay = { REG = 9 } }, "NVA_VIETNAM_1965_72")
check(named.name == "MINE" and named.cueDelay.REG == 9 and named.cueDelay.GRN == J.Doctrines.NVA_VIETNAM_1965_72.cueDelay.GRN,
  "custom table without base: on the fallback profile, keeps its own name")
local nob = J.getDoctrine({ ambush = 0.6 })
check(nob.cueSource == "ew" and nob.ambush == 0.6, "custom table, no base, no fallback: on SOVIET_PVO_1985")
local unk = J.getDoctrine("NO_SUCH", "US_MODERN")
check(unk == J.Doctrines.US_MODERN and F.logContains("unknown doctrine 'NO_SUCH'"), "unknown name: fallback, warned")
check(J.getDoctrine("NO_SUCH_EITHER") == J.Doctrines.SOVIET_PVO_1985 and J.getDoctrine(nil) == J.Doctrines.SOVIET_PVO_1985,
  "unknown name or nil without fallback: SOVIET_PVO_1985")

print(string.format("test_doctrine: %d passed, %d failed", passed, failed))
if failed > 0 then os.exit(1) end
