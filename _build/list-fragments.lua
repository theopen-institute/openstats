-- list-fragments.lua
-- Quarto/Pandoc Lua filter: list items that build as reveal fragments.
--
-- A list item that is nothing but a fragment span:
--   - [If this confuses you, you're not alone.]{.fragment fragment-index=2}
--   - ["assuming the null hypothesis is true"]{.fragment .red fragment-index=2}
-- becomes an <li> with the span's classes and attributes, so the bullet appears
-- with its text (a span alone would leave an empty bullet showing). Pandoc list
-- items can't carry attributes, so a list containing such an item is written out
-- as raw HTML. Items with anything else in them are left alone, e.g.
--   - Ice cream sales ↔ drownings [→ hot weather]{.fragment .blue}

-- The fragment span that makes up the whole of an item's first block, if any
local function fragment_span(item)
  local first = item[1]
  if not first or (first.t ~= "Plain" and first.t ~= "Para") then return nil end
  local inlines = first.content
  if #inlines ~= 1 or inlines[1].t ~= "Span" then return nil end
  if not inlines[1].classes:includes("fragment") then return nil end
  return inlines[1]
end

local function li_attributes(span)
  local attrs = { ' class="' .. table.concat(span.classes, " ") .. '"' }
  for key, value in pairs(span.attributes) do
    -- pandoc writes unknown attributes as data-*; do the same
    if not key:match("^data%-") then key = "data-" .. key end
    table.insert(attrs, " " .. key .. '="' .. value .. '"')
  end
  return table.concat(attrs)
end

local function blocks_html(blocks)
  return pandoc.write(pandoc.Pandoc(blocks), "html")
end

local function rewrite(list, open_tag, close_tag)
  if not FORMAT:match("revealjs") then return nil end

  local any = false
  for _, item in ipairs(list.content) do
    if fragment_span(item) then any = true end
  end
  if not any then return nil end

  local html = { open_tag }
  for _, item in ipairs(list.content) do
    local span = fragment_span(item)
    if span then
      local rest = { pandoc.Plain(span.content) }
      for i = 2, #item do table.insert(rest, item[i]) end
      table.insert(html, "<li" .. li_attributes(span) .. ">" .. blocks_html(rest) .. "</li>")
    else
      table.insert(html, "<li>" .. blocks_html(item) .. "</li>")
    end
  end
  table.insert(html, close_tag)
  return pandoc.RawBlock("html", table.concat(html, "\n"))
end

function BulletList(list)
  return rewrite(list, "<ul>", "</ul>")
end

function OrderedList(list)
  return rewrite(list, '<ol start="' .. list.start .. '">', "</ol>")
end
