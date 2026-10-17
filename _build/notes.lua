-- notes.lua
-- Quarto/Pandoc Lua filter for RevealJS speaker notes
--
-- Header usage:
--   ## Slide Title {notes="notes/week1_notes.md#published-research"}
--
-- Inline placeholder usage (block-level):
--   ::: {notes="notes/week1_notes.md#published-research"}
--   :::
--
-- Title slide (built from YAML title/subtitle, so there is no heading to attach to):
--   title-notes: "notes/week1_notes.md#title"
-- sets `title-notes-html`, which _build/title-slide.html places on the title slide.
--
-- Notes source file:
--   Any heading level with explicit IDs:
--     # Title {#title}
--     ## Section {#published-research}
--     ### Subsection {#some-subsection}
--
-- A reference that can't be resolved (missing file, missing #id, malformed value)
-- stops the render, so a typo can't silently drop a slide's notes.

local cache = {}

local function fail(msg)
  error("[notes.lua] " .. msg, 0)
end

local function read_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end

local function split_ref(ref)
  -- expects "path.md#id"
  local path, frag = ref:match("^(.-)#(.-)$")
  return path, frag
end

local function file_exists(path)
  local f = io.open(path, "r")
  if f then f:close(); return true end
  return false
end

local function join_path(base, p)
  if pandoc.path.is_absolute(p) then
    return p
  end
  return pandoc.path.join({ base, p })
end

local function candidate_bases()
  local bases = {}

  -- 1) Quarto project dir (most reliable in Quarto project mode)
  local proj = os.getenv("QUARTO_PROJECT_DIR")
  if proj and proj ~= "" then
    table.insert(bases, proj)
  end

  -- 2) Current working directory (can be useful depending on render context)
  if pandoc.system and pandoc.system.get_working_directory then
    local wd = pandoc.system.get_working_directory()
    if wd and wd ~= "" then
      table.insert(bases, wd)
    end
  end

  -- 3) Directory of the (temporary) input file (least reliable, but keep as fallback)
  local inputs = PANDOC_STATE and PANDOC_STATE.input_files or {}
  if inputs[1] then
    table.insert(bases, pandoc.path.directory(inputs[1]))
  end

  -- 4) Finally, literal "."
  table.insert(bases, ".")

  return bases
end

local function resolve_path(p)
  if pandoc.path.is_absolute(p) then
    return p
  end

  local tried = {}
  for _, base in ipairs(candidate_bases()) do
    local cand = join_path(base, p)
    table.insert(tried, cand)
    if file_exists(cand) then
      return cand
    end
  end

  fail("Could not find notes file " .. p .. ". Tried:\n  - " .. table.concat(tried, "\n  - "))
end

local function load_markdown_doc(path)
  if cache[path] then return cache[path] end

  local txt = read_file(path)
  if not txt then
    fail("Could not read notes file: " .. path)
  end

  local doc = pandoc.read(txt, "markdown")
  cache[path] = doc
  return doc
end

local function header_identifier(h)
  return (h.attr and h.attr.identifier) or ""
end

-- Extract content under the header with id=target_id, regardless of heading level.
-- Stop at next header with level <= matched header level.
local function extract_section_blocks(doc, target_id)
  local blocks = doc.blocks
  local start_i, target_level = nil, nil

  for i, b in ipairs(blocks) do
    if b.t == "Header" and header_identifier(b) == target_id then
      start_i = i + 1
      target_level = b.level
      break
    end
  end

  if not start_i then
    return nil, ("Section id not found: #%s"):format(target_id)
  end

  local out = {}
  for i = start_i, #blocks do
    local b = blocks[i]
    if b.t == "Header" and b.level <= target_level then
      break
    end
    table.insert(out, b)
  end

  return out, nil
end

-- Prevent headings inside notes from being interpreted as slides.
local function sanitize_notes(blocks)
  local div = pandoc.Div(blocks)
  div = div:walk({
    Header = function(h)
      return pandoc.Para({ pandoc.Strong(h.content) })
    end
  })
  return div.content
end

local function blocks_to_html(blocks)
  return pandoc.write(pandoc.Pandoc(blocks), "html")
end

-- Notes content for a "file.md#id" reference, as HTML (without the <aside>).
local function notes_html(ref)
  local p, frag = split_ref(ref)
  if not p or not frag or p == "" or frag == "" then
    fail('Bad notes value (expected "file.md#id"): ' .. tostring(ref))
  end

  local fullpath = resolve_path(p)
  local doc = load_markdown_doc(fullpath)

  local blocks, err = extract_section_blocks(doc, frag)
  if not blocks then
    fail(err .. " (in " .. fullpath .. ")")
  end

  return blocks_to_html(sanitize_notes(blocks))
end

local function make_notes_aside(ref)
  local html = notes_html(ref)
  if not html then return nil end
  return pandoc.RawBlock("html", "<aside class=\"notes\">\n" .. html .. "\n</aside>")
end

function Meta(meta)
  if not FORMAT:match("revealjs") then
    return nil
  end

  local ref = meta["title-notes"] and pandoc.utils.stringify(meta["title-notes"])
  if not ref or ref == "" then
    return nil
  end

  local html = notes_html(ref)
  if not html then
    return nil
  end

  meta["title-notes-html"] = pandoc.MetaBlocks({ pandoc.RawBlock("html", html) })
  return meta
end

function Header(h)
  if not FORMAT:match("revealjs") then
    return nil
  end

  local ref = h.attributes["notes"]
  if not ref or ref == "" then
    return nil
  end

  local aside = make_notes_aside(ref)
  if not aside then
    return nil
  end

  return { h, aside }
end

function Div(el)
  if not FORMAT:match("revealjs") then
    return nil
  end

  -- Inline block placeholder: ::: {notes="file.md#id"} :::
  local ref = el.attributes["notes"]
  if not ref or ref == "" then
    return nil
  end

  -- Don't interfere with explicit notes blocks: ::: {.notes} ... :::
  if el.classes and el.classes:includes("notes") then
    return nil
  end

  local aside = make_notes_aside(ref)
  if not aside then
    return nil
  end

  return aside
end