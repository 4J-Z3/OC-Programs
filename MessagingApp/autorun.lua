local fs = require("filesystem")
local term = require("term")
local computer = require("computer")
local proxy = ...
fs.mount( proxy, "/2c5")

function yesno(message)
  term.clear()
  os.sleep(0.1)
  term.write(message .. "\n")
  term.write("[Y/N]>")

  if ((io.stdin:read() or "n") .. "y"):match("^%s*[Yy]") then
    return true 
  end
  return false 
end

if yesno("Do you wish to copy APIs to /lib?") then
  if fs.copy("/mnt/2c5/guiManager.lua", "/lib/guiManager.lua") then
    term.write("\nguiManager.lua successfully coppied!\n")
    computer.beep(880)
  end
  os.sleep(0.1)
  if fs.copy("/mnt/2c5/guiElements.lua", "/lib/guiElements.lua") then
    term.write("\nguiElements.lua successfully coppied!\n")
    computer.beep(800)
  end

  if yesno("Do you want to Reboot?") then
    computer.shutdown(true)
  end

end

os.sleep(0.1)
term.clear()
os.exit()