-- notes-from.lua
-- Usage options:
-- 1) On a slide header:
--    ## Title {notes-from="notes.md#section-id"}
--
-- 2) Anywhere within a slide (e.g., at the end):
--    ::: {notes-from="notes.md#section-id"}
--    :::

local cache = {}

local function warn(msg)
  io.stderr:write("[notes-from.lua] " .. msg .. "\n")
end

local function read_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end

local function file_exists(path)
  local f = io.open(path, "r")
  if f then f:close(); return true end
  return false
end

local function load_markdown_doc(path)
  if cache[path] then return cache[path] end

  local txt = read_file(path)
  if not txt then
    warn("Could not read file: " .. path)
    cache[path] = pandoc.Pandoc({})
    return cache[path]
  end

  -- Parse external markdown into a Pandoc AST.
  -- Enable a couple of common extensions to better preserve header IDs/attributes.
  -- Add more extensions here if your notes rely on them.
  local doc = pandoc.read(txt, "markdown+header_attributes+auto_identifiers")

  cache[path] = doc
  return doc
end

local function header_id(h)
  return (h.attr and h.attr.identifier) or ""
end

local function extract_section_blocks(doc, target_id)
  local blocks = doc.blocks
  local start_i = nil
  local level = nil

  for i, b in ipairs(blocks) do
    if b.t == "Header" and header_id(b) == target_id then
      start_i = i + 1
      level = b.level
      break
    end
  end

  if not start_i then
    return nil, ("Section id not found: #%s"):format(target_id)
  end

  local out = {}
  for i = start_i, #blocks do
    local b = blocks[i]
    if b.t == "Header" and b.level <= level then
      break
    end
    table.insert(out, b)
  end

  return out, nil
end

local function split_ref(ref)
  -- expects "path.md#id"
  local path, frag = ref:match("^(.-)#(.-)$")
  return path, frag
end

local function resolve_path(p)
  if pandoc.path.is_absolute(p) then
    return p
  end

  -- 1) Try current working directory (often the project/doc dir for Quarto)
  local cwd = pandoc.system.get_working_directory()
  local candidate = pandoc.path.join({ cwd, p })
  if file_exists(candidate) then
    return candidate
  end

  -- 2) Try the "source_url" directory (directory of the main source file), if set
  local src = PANDOC_STATE and PANDOC_STATE.source_url
  if src and src ~= "" then
    candidate = pandoc.path.join({ src, p })
    if file_exists(candidate) then
      return candidate
    end
  end

  -- 3) Try Pandoc resource paths (useful when Quarto stages files)
  local rpaths = (PANDOC_STATE and PANDOC_STATE.resource_path) or {}
  for _, rp in ipairs(rpaths) do
    candidate = pandoc.path.join({ rp, p })
    if file_exists(candidate) then
      return candidate
    end
  end

  -- 4) Fallback to the first input file directory (your original approach)
  local inputs = PANDOC_STATE and PANDOC_STATE.input_files or {}
  if inputs[1] then
    local base = pandoc.path.directory(inputs[1])
    candidate = pandoc.path.join({ base, p })
    return candidate
  end

  -- 5) Final fallback: relative as-is
  return p
end

local function make_notes_div(ref)
  local p, frag = split_ref(ref)
  if not p or not frag then
    warn('Bad notes-from value (expected "file.md#id"): ' .. tostring(ref))
    return nil
  end

  local fullpath = resolve_path(p)
  local doc = load_markdown_doc(fullpath)

  local blocks, err = extract_section_blocks(doc, frag)
  if not blocks then
    warn(err .. " (in " .. fullpath .. ")")
    return nil
  end

  -- RevealJS speaker notes container (recognized by Quarto/Pandoc/RevealJS)
  return pandoc.Div(blocks, pandoc.Attr("", { "notes" }))
end

function Header(h)
  -- Only act for revealjs outputs (avoid affecting other formats).
  if not FORMAT:match("revealjs") then
    return nil
  end

  local ref = h.attributes and h.attributes["notes-from"]
  if not ref or ref == "" then
    return nil
  end

  local notes_div = make_notes_div(ref)
  if not notes_div then
    return nil
  end

  -- Insert notes immediately after the header (within the slide).
  return { h, notes_div }
end

function Div(d)
  -- Allow a slide-local marker anywhere in the slide:
  -- ::: {notes-from="notes.md#section-id"} :::
  if not FORMAT:match("revealjs") then
    return nil
  end

  local ref = d.attributes and d.attributes["notes-from"]
  if not ref or ref == "" then
    return nil
  end

  local notes_div = make_notes_div(ref)
  if not notes_div then
    return nil
  end

  -- Replace the marker div with the actual notes div.
  return notes_div
end