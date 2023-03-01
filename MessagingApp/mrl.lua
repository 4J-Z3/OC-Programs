local comp = require("component")
local computer = require("computer")
local term = require("term")
local event = require("event")
local unicode = require("unicode")
local thread = require("thread")

local gpu = comp.gpu
local modem = comp.modem
local keyboard = comp.keyboard

local port = 25565
local user = ""
local message = ""
local programName = "BoxARocks_'s Messaging Program V0.3.2623"
local notificationSnd = false
local running = false

local backGroundColor = 0x101010
local foreGroundColor = 0xFFB000

local w, h = gpu.getResolution()

gpu.setBackground(backGroundColor)
gpu.setForeground(foreGroundColor)

--[[

you should make another lua file and put some of these graphical funstions in their and call it an api it would cleans this file up a lot and look neat and clean

]]

--centers text on the screen
local function TextCenter(Text, axis)
 return math.floor( (axis/2) - (string.len(Text) / 2) )
 end

--this function will clear the screen and put the program name uptop
local function clearScreen(addTitle)
  gpu.fill( 1,1, w,h, " ")
 if addTitle then
  gpu.fill( 1,1, w,1, "=")
  gpu.set( TextCenter(programName, w), 1, programName )
 end
end

--this generates a loading bar at the provided coords with the provided width and height
local function loadingBar(x, y, width, height)
 gpu.set( x - 1, y, "[")
 gpu.fill(x, y, width, height, unicode.char(9617))
 gpu.set( width + x, y, "]")
 local percentage = 0
 os.sleep(0.3)
 while percentage <= 100 do 
  if percentage >= 100 then
   percentage = 100
   break
  else
    percentage = percentage + 1
  end
  gpu.fill( x,y, (percentage * width) / 100,height, unicode.char(9608))
  gpu.set( width + x + 2, y, percentage .."%")
  os.sleep()
 end
end

--This draws a box starting at the X Y coords and with the provided width and height
local function drawBox(x, y, width, height)
 --left corners
 gpu.set(x, y, unicode.char(9487)) -- top left
 gpu.set(x, y + height - 1, unicode.char(9495)) -- bottom left
 --Right corners
 gpu.set(x + width - 1, y, unicode.char(9491)) -- top right
 gpu.set(x + width - 1, y + height - 1, unicode.char(9499)) -- bottom right
 --Fill edges
 gpu.fill(x + 1, y, width - 2, 1, unicode.char(9473)) -- top
 gpu.fill(x + 1, y + height - 1, width - 2, 1, unicode.char(9473)) -- bottom
 gpu.fill(x, y + 1, 1, height - 2, unicode.char(9475)) -- left
 gpu.fill(x + width - 1, y + 1, 1, height - 2, unicode.char(9475)) -- right
end

--this functions highlights the word supplied and places is at the x y coords
local function highlightText(x, y, word, Highlight)
 gpu.set(x,y,word)
 for i = 1, #word do
  local c = word:sub(i,i)
  if c == Highlight then
   gpu.setForeground(0xFFFFFF)
   gpu.set(x + (i - 1), y, Highlight)
   gpu.setForeground(foreGroundColor)
  end
 end
end

--this functions creates a dialouge popup based on the specified parameters
local function makePopup(x, y, width, height, title)
  gpu.fill(x,y ,string.len(title) + 2 + width, height, " ")
  drawBox(x ,y, string.len(title) + 2 + width, height)
  gpu.set(x + 1 + (width/2), y, title)
end

function unknownEvent()
  -- do nothing if the event wasn't relevant
end

-- table that holds all event handlers
-- in case no match can be found returns the dummy function unknownEvent
local myEventHandlers = setmetatable({}, { __index = function() return unknownEvent end })

-- The main event handler as function to separate eventID from the remaining arguments
function handleEvent(eventID, ...)
  if (eventID) then -- can be nil if no event was pulled for some time
    myEventHandlers[eventID](...) -- call the appropriate event handler with all remaining arguments
  end
end

--Main

clearScreen(true)

computer.beep(800)

os.sleep(1)

gpu.set( TextCenter("Initializing", w), 4, "Initializing")

loadingBar( TextCenter("Initializing", w) - 6,5,24,1)

computer.beep(800)

os.sleep(1)

 gpu.set( TextCenter("Term Availability", w), 7,  "Term Availability")
 --loops 4 times printing ....
for i = 0, 3 do
 gpu.set( TextCenter("Term Availability", w) + string.len("Term Availability") + i, 7, ".")
 os.sleep(0.3)
end

computer.beep(800)

gpu.set( TextCenter("Checking Port", w), 9, "Checking Port" )
 --loops 4 times printing ....
for i = 0, 3 do
 gpu.set( TextCenter("Checking Port", w) + string.len("Checking Port") + i, 9, ".")
 os.sleep(0.6)
end

--checks if the port is open if it is then it continues
if modem.isOpen(port) then
 os.sleep(0.6)
 computer.beep(800)
 gpu.set(TextCenter("Port Open: " ..port, w), 11, "Port Open: " ..port)
else
 os.sleep(0.6)
 computer.beep(800)
 gpu.set( TextCenter("No Port Open", w), 11, "No Port Open")
 os.sleep(2)

 ::OpenPort::
 computer.beep(800)
 gpu.set( TextCenter("Do you want to open a port on: " .. port .. "?", w), 11, "Do you want to open a port on: " .. port .. "?")
 gpu.set( TextCenter("[Y/N]>", w), 12, "[Y/N]>")
 term.setCursor( TextCenter("[Y/N]>", w) + 6, 12)

 if ((io.stdin:read() or "n") .. "y"):match("^%s*[Yy]") then
   ::OpenPortRetry::
   if modem.open(port) then
    gpu.fill(TextCenter("Do you want to open a port on: " .. port .. "?", w), 11, string.len("Do you want to open a port on: " .. port .. "?") , 2, " ")
    gpu.set( TextCenter("Success!", w), 11, "Success!")
    os.sleep(1)
   else
    gpu.fill(TextCenter("Do you want to open a port on: " .. port .. "?", w), 11, string.len("Do you want to open a port on: " .. port .. "?") , 2, " ")
    gpu.set( TextCenter("Error cannot open port on: " ..port, w), 11, "Error cannot open port on: " ..port)
   end
 end
end

os.sleep(1)
clearScreen(true)

running = true

--Displays settings menu
local function displaySettings()
 gpu.fill(3,4, w - 4, h - 5, " ")
 drawBox(2,3,w - 2,h - 3)
 --Change able variables
 highlightText(4,5, "Current port: " ..port, "C")
 highlightText(4,7, "Notification Sound: " ..tostring(notificationSnd), "N")
 if modem.isOpen(port) then
  highlightText(4,9, "Close port", "p")
 else
  gpu.set(4,9, "Open ")
  highlightText(9,9, "port", "p")
 end
 --info
 gpu.set(w - string.len("Port Status...") - 8,5, "Port Status... " ..tostring(modem.isOpen(port)))
end

--Displays help menu
local function displayHelp(category)
  gpu.fill(3,4, w - 4, h - 5, " ")
  drawBox(2,3,w - 2,h - 3)
  if category == 0 then
    gpu.set(TextCenter("Welcome to " .. programName, w),5, "Welcome to " .. programName)
    gpu.set(TextCenter("This is the user help screen.", w), 6, "This is the user help screen.")
    gpu.set(4, 8, "This page is where you can find help on certain functions of this program.")
    highlightText(4, 10, "[Controls]", "C")
    highlightText(4, 11, "[Functions]", "F")
  elseif category == 1 then
    gpu.set(TextCenter("[Controls]", w),5, "[Controls]")
  elseif category == 2 then
    gpu.set(TextCenter("[Functions]", w),5, "[Functions]")
  end
end

local function drawMenu(enabled)
 if enabled then
  highlightText(5, 2, "Quit", "Q")
  highlightText(string.len("Quit") + 10, 2, "Settings", "S")
  highlightText(string.len("Quit") + string.len("Settings") + 15, 2, "Info", "I")
 else
  gpu.set(5, 2, "Quit")
  gpu.set(string.len("Quit") + 10, 2, "Settings")
  gpu.set(string.len("Quit") + string.len("Settings") + 15, 2, "Info")
 end
end

--displays chat
local function displayChat()
  gpu.fill(3,4, w - 4, h - 5, " ")
  drawBox(2,3,w - 2,h - 3)
  gpu.set(3, h - 2, ">> ")
  gpu.fill(6, h-2, w - 8, 1, " ")
  gpu.set(6, h - 2, message)
end

--This is the main

computer.beep(800)

drawMenu(false)

--draw the text box
drawBox(2,3,w - 2,h - 3)
displayChat()

--important variables that i am too lazy to move up top and for ease of access
local altMenu = false 
local typing = true
local settingsOpen = false
local infoOpen = false
--local dialougeOpen = false

--this function will clear any variables set to true besides some
local function clearOpenedMenus()
  settingsOpen = false
  infoOpen = false
end

--[[

so as of right now when you press tab it completely closes everything im gonna need to change it so it goes back a level if you are in a multi-layerd gui

]]

function myEventHandlers.key_up(address, char, code, playerName)
 --io.stdout:write("Char: " .. char, "Code: " .. code, "\nTest: " .. string.char(char) .. "\n") --for testing purposes
  
  if (code == tonumber(0x38)) or (code == tonumber(0xB8)) then --Alt Menu
    
   if altMenu then
    altMenu = false
    typing = true
    drawMenu(false)
   else
    altMenu = true
    typing = false
    drawMenu(true)
   end
 
  elseif (char == string.byte("Q")) or (char == string.byte("q")) then --Quit
   
    if altMenu then
     running = false
     os.sleep()
     clearScreen(true)

     if modem.isOpen(port) then
      gpu.set(TextCenter("Do you want to close " .. port .. "?", w), TextCenter("Goodbye!", h) - 2, "Do you want to close " .. port .. "?")
      gpu.set(TextCenter("[Y/N]>", w), TextCenter("Goodbye!", h) - 1, "[Y/N]>")
      term.setCursor(TextCenter("[Y/N]>", w) + 6, TextCenter("Goodbye!", h) - 1)
      if ((io.stdin:read() or "n") .. "y"):match("^%s*[Yy]") then
       modem.close(port)
      end
     end

     clearScreen(true)

     gpu.set(TextCenter("Goodbye!", w), TextCenter("Goodbye!", h), "Goodbye!")
     os.sleep(2)
     clearScreen(false)
     term.setCursor(1,1)
     os.exit()
    end

  elseif (char == string.byte("S")) or (char == string.byte("s")) then --Settings
   
    if altMenu then
     clearOpenedMenus()
     settingsOpen = true
     altMenu = false
     drawMenu(false)
     displaySettings()
    end

  elseif (char == string.byte("I")) or (char == string.byte("i")) then
    
    if altMenu then
     clearOpenedMenus()
     infoOpen = true
     altMenu = false
     drawMenu(false)
     displayHelp(0)
    end

  elseif (code == tonumber(0x0F)) then --exit current screen
   
    if altMenu then
      altMenu = false
      typing = true
      drawMenu(false)
      displayChat()
    elseif settingsOpen then
      typing = true
      settingsOpen = false
      displayChat()
    elseif infoOpen then
      typing = true
      infoOpen = false
      displayChat()
    end

  elseif (char == string.byte("C")) then
   
    if settingsOpen then
      makePopup(TextCenter("Change Port", w) - 2, h/2 - 1, 4, 3, "Change Port")
      term.setCursor(TextCenter("Change Port", w) + 4, h/2)
      local newPort = io.stdin:read(5)
      local oldPort = port
      if tonumber(newPort) ~= nil then
        newPort = tonumber(newPort)
       if newPort <= 65535 then
        if modem.isOpen(oldPort) then
          modem.close(oldPort)
          modem.open(newPort)
          port = newPort
        else
          port = newPort
        end
       end
      end
      displaySettings()
    elseif infoOpen then
      displayHelp(1)
    end

  elseif (char == string.byte("p")) then
   
    if settingsOpen then
      if modem.isOpen(port) then
      modem.close(port)
      displaySettings()
      else
      modem.open(port)
      displaySettings()
      end
    end

  end

  if typing then
    if string.char(char):match("%w") or string.char(char):match("%p") or string.char(char):match(" ") then
      message = message .. string.char(char)
      if string.len(message) >= w - 7 then
        io.stdout:write("cutoff")
      end
      gpu.fill(6, h-2, w - 8, 1, " ")
      gpu.set(6, h - 2, message)
      --io.stdout:write( "Test: " .. string.char(char) .. "\n")
      --io.stdout:write( "Test2: " .. string.char(char) .. "\n" )
    elseif (char == 8) and (string.len(message) ~= 0) then
      message = message:sub(1, -2)
      gpu.fill(6, h-2, w - 8, 1, " ")
      gpu.set(6, h - 2, message)
    end
  end

end

thread.create(function() 
  while running do
    drawBox(2,3,w - 2,h - 3)
    os.sleep()
  end
end)

while running do
  handleEvent(event.pull())
end