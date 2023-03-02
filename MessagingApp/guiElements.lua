--this was based off of dustpuppys gui libary

local component = require("component")
local event = require("event")
local unicode = require("unicode")
local gui = require("guiManager")
local gpu = component.gpu

local screenWidth, screenHeight = gpu.getResolution()

local guiElements = {}

local previousElement = {
  ["id"] = "none",
  ["text"] = "none",
  ["x"] = 0,
  ["y"] = 0,
  ["width"] = 0,
  ["height"] = 0
}

local backGroundColor = 0x101010
local foreGroundColor = 0xFFB000

function updatePrevElement(element)
  previousElement["id"] = element.id
  previousElement["text"] = element.text
  previousElement["x"] = element.x
  previousElement["y"] = element.y
  previousElement["width"] = element.width
  previousElement["height"] = element.height
end

function correctPos(win, element)
  local x = element.x 
  local y = element.y
  local width = element.width
  local height = element.height

  while x + width > win.x + win.width - 1 do -- the element is too long
    width = width - 1
  end

  if width < 0 then
    width = 0
  end

  while y + height > win.y + win.height do -- the element is too long
    height = height - 1
  end

  while x + width > win.x + win.width - 1 do -- the element is too long
    height = height - 1
  end

  return x, y, width, height
end

local function getPosAlignment(win, element)
  if element.alignment == "left" then
    return win.x + element.x
  elseif element.alignment == "center" then
    return win.x + self.x + self.w - math.floor(string.len(string.sub(element.text, 1, element.width))/2)
  elseif element.alignment == "right" then
    return win.x + element.x + self.width - string.len(string.sub(element.text, 1, element.width))
  end
end

local function wrap(str, limit)
  local Lines, here, limit, found = {}, 1, limit or 72, str:find("(%s+)()(%S+)()")
  if found then
      Lines[1] = string.sub(str,1,found-1)  -- Put the first word of the string in the first index of the table.
  else Lines[1] = str end
  str:gsub("(%s+)()(%S+)()",
      function(sp, st, word, fi)  -- Function gets called once for every space found.
          splitWords(Lines, limit)

          if fi-here > limit then
              here = st
              Lines[#Lines+1] = word                                             -- If at the end of a line, start a new table index...
          else Lines[#Lines] = Lines[#Lines].." "..word end  -- ... otherwise add to the current table index.
      end)
  splitWords(Lines, limit)

  return Lines
end

function drawLabel(win, element)
  local x, y, width, height = correctPos(win, element)

  if element.isActive then
    --change foreground and background to active variants
    element.isActive = false
  else
    --change active foreground and background to normal variants
    element.isActive = false
  end

  gpu.fill(x, y, width, height, " ")
  local tPos = getPosAlignment(win, element)

  if element.wordWrap then
    local text = wrap(element.text, element.width)
    for i = 1, #text do
      if height >= 1 and i <= height then
        local stringLen = (tPos + string.len(element.text))
        if stringLen > x + width then
          stringLen = x + width - stringLen - 1
        end
        if tPos <= win.x + win.width - 2 then
          gpu.set(tPos, y + i - 1, string.sub(text[i], i, stringLen))
        end
      end
    end
  else
    if height >= 1 then
      local stringLen = (tPos + string.len(element.text))
      if stringLen > x + width then
        stringLen = x + width - stringLen - 1
      end
      if tPos <= win.x + win.width - 2 then
        gpu.set(tPos, y, string.sub(element.text, i, stringLen))
      end
    end
  end
  
end

function handleButton(win, element, x, y)
   updatePrevElement(element)
   self.isActive = true
   drawLabel(win, element)
   os.sleep(0.1)
   self.isActive = false
   drawLabel(win, element)
  return false
end

-- Gui elements

function guiElements.newButton(x, y, w, h, text, key, callback)
  local button = gui.newElement(x, y, w, h, text, callback)
  button.key = key
  button.drawCallback = drawLabel
  button.background = backGroundColor
  button.foreground = foreGroundColor
  button.alignment = "center"
  button.handleCallback = handleButton
  return button
end

return guiElements