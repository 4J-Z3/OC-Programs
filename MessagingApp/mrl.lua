local comp = require("component")
local computer = require("computer")
local term = require("term")
local event = require("event")
local unicode = require("unicode")
local gpu = comp.gpu
local modem = comp.modem
local keyboard = comp.keyboard
local port = 25565
local notificationSnd = false

local running = true

local w, h = gpu.getResolution()

local programName = "BoxARocks_'s Messaging Program V0.2.2623"

gpu.setBackground(0x101010)
gpu.setForeground(0xFFB000)

local function TextCenter(Text)
 return math.floor( (w/2) - (string.len(Text) / 2) )
 end

--this function will clear the screen and put the program name uptop
local function clearScreen(addTitle)
 for i = 0, h do
  gpu.fill( 1,1, w,i, " ")
  os.sleep()
 end
 if addTitle then
  gpu.fill( 1,1, w,1, "=")
  gpu.set( TextCenter(programName), 1, programName )
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

function unknownEvent()
  -- do nothing if the event wasn't relevant
end

local function displaySettings()
  gpu.set(3,5, "Current Port: " ..port)
  gpu.set(3,7, "Notifiction Sound: " ..tostring(notificationSnd))
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

gpu.set( TextCenter("Initializing"), 4, "Initializing")

loadingBar( TextCenter("Initializing") - 6,5,24,1)

computer.beep(800)

os.sleep(1)

 gpu.set( TextCenter("Term Availability"), 7,  "Term Availability")
 --loops 4 times printing ....
for i = 0, 3 do
 gpu.set( TextCenter("Term Availability") + string.len("Term Availability") + i, 7, ".")
 os.sleep(0.3)
end

computer.beep(800)

gpu.set( TextCenter("Checking Port"), 9, "Checking Port" )
 --loops 4 times printing ....
 for i = 0, 3 do
 gpu.set( TextCenter("Checking Port") + string.len("Checking Port") + i, 9, ".")
 os.sleep(0.6)
end
if modem.isOpen(port) == true  then
 os.sleep(0.6)
 computer.beep(800)
 gpu.set( TextCenter("Port Open On: " ..port), 11, "Port Open: " ..port)
else
--100 lines milestone
os.sleep(0.6)
 computer.beep(800)
 gpu.set( TextCenter("No Port Open"), 11, "No Port Open")
end
os.sleep(0.5)
clearScreen(true)


--This is the main

computer.beep(800)

gpu.set(5, 2, "Quit")
gpu.set(string.len("Quit") + 10, 2, "Settings")
gpu.set(string.len("Quit") + string.len("Settings") + 15, 2, "Info")

--draw the text box
drawBox(2,3,w - 2,h - 3)

--important variables that i am too lazy to move up top
local tabbed = false 
local chatting = true
local settingsOpen = false
local infoOpen = false

function myEventHandlers.key_up(address, char, code, playerName)
  if char == string.byte(unicode.char(9)) then
   gpu.set(3,4,"Tab")
   if tabbed then
    tabbed = false
    chatting = true

    gpu.set(5, 2, "Quit")
    gpu.set(string.len("Quit") + 10, 2, "Settings")
    gpu.set(string.len("Quit") + string.len("Settings") + 15, 2, "Info")

   else
    tabbed = true
    chatting = false
    
    gpu.setForeground(0x101010)
    gpu.setBackground(0xFFB000)
    gpu.set(5, 2, "Q")
    gpu.set(string.len("Quit") + 10, 2, "S")
    gpu.set(string.len("Quit") + string.len("Settings") + 15, 2, "I")
    gpu.setBackground(0x101010)
    gpu.setForeground(0xFFB000)
    gpu.set(6, 2, "uit")
    gpu.set(string.len("Quit") + 11, 2, "ettings")
    gpu.set(string.len("Quit") + string.len("Settings") + 16, 2, "nfo")

   end
  elseif(char == string.byte("q")) or (char == string.byte("Q")) then
    if tabbed then
      clearScreen(true)
      gpu.set( TextCenter("Goodbye!"), math.floor( (h/2) - (string.len("Goodbye!") / 2) ), "Goodbye!")
      os.sleep(1)
      running = false
      tabbed = false
      clearScreen(false)
    end 
  elseif(char == string.byte("s")) or (char == string.byte("S")) then
    if tabbed then
      if infoOpen == false then
        if settingsOpen then
          settingsOpen = false
          gpu.fill( 1,1, w,1, "=")
         gpu.set( TextCenter(programName), 1, programName )
         gpu.fill(3,4, w - 4,h - 5, " ")
         else
         gpu.fill( 1,1, w,1, "=")
         gpu.set( TextCenter("Settings"), 1, "Settings" )
         settingsOpen = true
         displaySettings()
        end
      end
    end
  end
end

while running do
  handleEvent(event.pull())
end
