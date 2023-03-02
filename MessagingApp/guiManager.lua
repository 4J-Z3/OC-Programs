--this was HEAVLY based off of dustpuppys gui libary. and I dont plan on giving it out
--also i like your gui dustpuppys

--TODO
--add a deslected thing for the elemts and guis and stuff so when
--you press a button and it doesnt try to open two of the same guis with tha button

--for some dumbass reason it only progress the whole os when you only press a key

local component = require("component")
local event = require("event")
local unicode = require("unicode")
local gpu = component.gpu

local screenWidth, screenHeight = gpu.getResolution()

local backgroundColor = 0x101010
local foregroundColor = 0xFFB000

-- Vertical, Horizontal, Top left then right, Bottom left then right
local borders = {
  ["Bold"] = {0x2503, 0x2501, 0x250F, 0x2513, 0x2517, 0x251B}
}

local windowBorder = borders["Bold"]

local guiManager = {}

local guiWindowList = {}

local function MultiThread( _timeout )
  if coroutine.running()==mainThread then
    local mintime = _timeout or math.huge
    local co=next(timeouts)
    while co do
      if coroutine.status( co ) == "dead" then
        timeouts[co],co=nil,next(timeouts,co)
      else
        if timeouts[co] < mintime then mintime=timeouts[co] end
        co=next(timeouts,co)
      end
    end
    if not next(timeouts) then
      computer.pullSignal=computer.SingleThread
      computer.pushSignal("AllThreadsDead")
    end
    local event={computer.SingleThread(mintime)}
    local ok, param
    for co in pairs(timeouts) do
      ok, param = coroutine.resume( co, table.unpack(event) )
      if not ok then timeouts={} error( param )
      else timeouts[co] = param or math.huge end
    end
    return table.unpack(event)
  else
    return coroutine.yield( _timeout )
  end
end

function threadInit()
  mainThread=coroutine.running()
  timeouts={}
end

--Just clears the screen
function clearScreen()
  gpu.setBackground(backgroundColor)
  gpu.setForeground(foregroundColor)

  gpu.fill(1,1, screenWidth, screenHeight, " ")
end

function drawAllGuis()
  for i = 1, #guiWindowList do
    if not guiWindowList[i].deslected then
      guiWindowList[i]:Draw()
    end
  end
end

--Gui element

local elements = {}

elements.__index = elements

function elements:New(id, x, y, width, height, text, callback)
  local element = setmetatable({
    id = id or "unknown",
    x = x,
    y = y,
    width = width,
    height = height,
    text = text,
    keyToPress = keyToPress,
    alignment = "center",
    wordWrap = false,
    callback = callback or nil,
    drawCallback = nil,
    handleCallback = nil,
    background = nil,
    foreground = nil,
    activeBackground = nil,
    activeForeground = nil,
    isActive = false,
    min = 0,
    max = 0,
    value = 0,
    --steps = 0,
    state = false,
    data = {},
    selected = 1,
    type = 1
  }, elements)
  return element
end

local function checkElementPressed(win, key)
  for i = 1, #win.windowElements do
    if win.windowElements[i].isActive then
      return
    else
      if not win.deslected then
        if string.byte(win.windowElements[i].key) == char then
          if not win.windowElements[i].handleCallback then
           if not win.windowElements[i].handleCallback() then
            return
           end
          end
          if win.windowElements[i].callback then
            win.windowElements[i].callback(win, win.windowElements[i])
          end
        end
      end
    end
  end
end

-- Gui window
local guiWindow = {}

guiWindow.__index = guiWindow

function guiWindow:New(x, y, width, height, text)
  local window = setmetatable({
    x = x,
    y = y,
    width = width,
    height = height,
    text = text,
    id = #guiWindowList + 1,
    buffer = {},
    windowElements = {},
    disableButtons = false,
    hide = false,
    deslected = true,
    deslectedCallback = nil,
    refresh = true
  }, guiWindow)
  table.insert(guiWindowList, window)
  return window
end

--saves the line
function guiWindow:saveScreen()
  self.buffer = {}
  for posX = self.x, self.x + self.width do
    local ch, fc, bc = gpu.get(posX,self.y) -- gets the current character foreground color and background color
    table.insert(self.buffer, {ch, fc, bc})
  end
  return buffer
end

--loads the provided buffer/screen
function guiWindow:loadScreen(screen)

  local oldBg, oldFg

  for key, value in pair(self.buffer) do
    if value[3] ~= oldBg then
      gpu.setBackGround(value[3])
      oldBg = value[3]
    end

    if value[2] ~= oldFg then
      gpu.setForeGround(value[2])
      oldFg = value[2]
    end

    gpu.set(self.x + key - 1, self.y, value[3])
  end
end

function guiWindow:Draw()
  self:saveScreen()

  gpu.fill(self.x, self.y, self.width, 1, " ")

  gpu.fill(self.x, self.y, self.width, self.height, " ")

  --corners
  gpu.set(self.x, self.y, unicode.char(windowBorder[3]))
  gpu.set(self.x, self.y + self.height - 1, unicode.char(windowBorder[5]))
  gpu.set(self.x + self.width - 1, self.y, unicode.char(windowBorder[4]))
  gpu.set(self.x + self.width -1, self.y + self.height - 1, unicode.char(windowBorder[6]))

  --edges
  gpu.fill(self.x + 1, self.y, self.width - 2, 1, unicode.char(windowBorder[2])) --Top
  gpu.fill(self.x, self.y + 1, 1, self.height - 2, unicode.char(windowBorder[1])) --Left
  gpu.fill(self.x + 1, self.y + self.height - 1, self.width - 2, 1, unicode.char(windowBorder[2])) --Bottom
  gpu.fill(self.x + self.width - 1, self.y + 1, 1, self.height - 2, unicode.char(windowBorder[1])) --Right

  if #self.text ~= 0 then
    if string.len(self.text) <= self.width - 4 then
      gpu.set(self.x + math.floor(self.width/2) - math.floor(string.len(" " .. self.text .. " ")/2), self.y, " " .. self.text .. " " )
    else
      gpu.set(self.x + 1, self.y, string.sub(self.text, 1, self.width - 4) .. "~")
    end
  end


  for i = 1, #self.windowElements do
    self.windowElements[i].drawCallback(self, self.windowElements)
  end
end

function guiWindow:checkKey(key)
  if self.deslected then
    return
  end
  for key, value in pairs(self.windowElements) do
    if self.id < #guiWindowList then
      guiManager.selectGui(self)
    end
    checkElementPressed(self, key)
  end
end

  --lets see if this will work lol
local function keyListenerUp(address, char, code, userName)
  for i = 1, #guiWindowList do
    for j = 1, #guiWindowList[i].windowElements do
      if string.byte(guiWindowList[i].windowElements[j].key) == char then
        guiWindowList[i]:checkKey(guiWindowList[i].windowElements[j].key)
      end
    end
  end
end

local function autoUpdateTimerCallback()
  MultiThread()
end

--guiManage functions

event.listen("key_up", keyListenerUp)
--event.listen("key_down", keyListenerDown)
--autoUpdateTimer = event.timer(0.1, autoUpdateTimerCallback, math.huge)
threadInit()

function guiManager.newWindow(x, y, width, height, text)
  return guiWindow:New(x, y, width, height, text)
end

function guiManager.selectGui(gui)
  table.remove(guiWindowList, gui.id)
  table.insert(guiWindowList, gui)
  gui.deslected = false
  clearScreen()
  drawAllGuis()
end

function guiManager.deselectGui(gui)
  if gui.deslectedCallback then
    if not gui.deslectedCallback(gui) then
      return
    end
  end
  gui.deslected = true
  for i = #guiWindowList, 1, -1 do
    if not guiWindowList[i].deslected then
      guiManager.selectGui(guiWindowList[i])
      break
    end
  end
  clearScreen()
  drawAllGuis()
end

function guiManager.closeGui(gui)
  table.remove(guiWindowList, gui.id)
  gui = nil
  clearScreen()
  drawAllGuis()
end

--elements

function guiManager.newElement(id, x, y, width, height, text, callback)
  return elements:New(id, x, y, width, height, text, callback)
end

function guiManager.addElement(gui, element)
  print(gui.windowElements)
  table.insert(gui.windowElements, element)
end

return guiManager
