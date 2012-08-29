-- Frames by Jan
-- You are free to spread it :)
-- You may ONLY edit this program by adding mods to it,
-- using the newMod() function!
-- If you want to mod it in any otherway, or need a hook,
-- or have a suggestion, please go to Jan on the Computercraft forums.
-- ddd
--
-- This program is called Frames because there are multiple
-- 'windows' which you can run at the same time
-- it has nothing to do with Microsoft Windows :) (ugh ugh)

-- From 1.1 to 1.2:
-- Made taskbar automaticly choose the right width
-- (More programs; smaller taskbar items)
-- Fixed the 'edit' problem, because 'edit' uses negative x-pos
-- Made a 'preloop' hook, which runs before starting the mainloop.
-- Made the 'shared' variable: should be used for windows-things.
-- Frames only updates screen when something in the GUI had changed
-- There must be at least 0.04 seconds between screen updates.
-- The 0.04 value is changable, and called the frame_limiter.
-- Started with Frames update. Type 'update' to see if there is a new version

-- Vars

local vers = "Frames Beta 1.4"
local header = ""
local main = ""
local tail = ""
local defaultmods = ""

-- This is the assembleit function. It gets executed at the end of the file


function assembleit()
 print("Autoassembler for "..vers)
 fs.makeDir("frx/mods")
 if not fs.exists("frx/mods/default") then
 handle = io.open("frx/mods/default","w")
 handle:write(defaultmods)
 handle:close()
 end

 local modstoload={}
 for a,b in pairs(fs.list("frx/mods")) do
 local handle = io.open("frx/mods/"..b)
 if handle~=nil then
  local modtext = handle:read("*a")
  handle:close()
  print("Found: "..b)
  table.insert(modstoload,modtext)
 end
 end
 local fuuu = header..vers..main.."\n"
 for a,b in ipairs(modstoload) do
  fuuu = fuuu .. "\n" .. b
 end
 fuuu = fuuu..tail
 print("Saving text")
 handle = io.open("frx/assem","w")
 handle:write(fuuu)
 handle:close()
 print("Running in shell...")
 shell.run("frx/assem")
end



--- Here is the program text

header=[[
local version = "]]


tail = [[
startwin()]]


main=[["


-- PART II ESSENTIALS FOR ALL
local p = {}
local q = 1
local focus=1
local rarg
local larg
local lresult
local fw
local files={}
local mods = {}
local shared = {}
shared.updateurl="http://janvanrosmalen.nl/vn/winupdate.txt"
shared.render=true
shared.num=0
shared.limiter=0.04
shared.tasksize=8
shared.maxtasksize=13
shared.livings=1
shared.updates=0
shared.needupdate=true
shared.forceupdate=false
shared.newest = "error"
local isFaked =true
local errr = ""
local bug = ""
local currentmod
local hooks = {}
local hooknames = {}

function pack(...)
 return arg
end





--- THE SHELLS




-- PART II: TERM VIRTUALISATION

function requpdate()
if q==focus then
shared.needupdate=true
end
end



local u ={}
u.os = {}
u.os.version = os.version
os.version = function() return u.os.version().." window "..q end

u.term = {}
for a,b in pairs(term) do
u.term[a] = b
end
local realw,realh = term.getSize()

local video={}
local pos={}
pos.x=1
pos.y=1
local img=1
local w = 1
local h = 1

function fakeIt()
term.clear = function()
 requpdate()
 video[img]={}
 for n=1, h do
  video[img][n]=string.rep(" ", w)
 end
end

term.scroll = function(n)
 requpdate()
 local function scrollOne()
  for n=2, h do
   video[img][n-1]=video[img][n]
   video[img][n]=string.rep(" ", w)
  end
 end
 for a=1, n do scrollOne() end
end

term.clearLine = function(n)
 requpdate()
 video[img][pos.y]=string.rep(" ", w)
end

term.setCursorPos = function(n1, n2)
  requpdate()
  pos.x=n1
  pos.y=n2
end

term.getSize = function()
return w,h
end

term.getCursorPos = function()
 return pos.x,pos.y
end


term.write = function(txt)
    requpdate()
    if pos.y < 1 then return end
    if pos.x < 1 then
					txt=txt:sub(2-pos.x)
					pos.x=1
				end
    if type(txt)=="nil" then txt="" end
    if string.len(txt)>w-(pos.x-1) then
	  txt=string.sub(txt, 1, (w-(pos.x-1))-2*(w-(pos.x-1)))
	end
	  if pos.x==1 then
	    t=""
	  else
	    t=string.sub(video[img][pos.y], 1, pos.x-1)
	  end
	  if pos.x+string.len(txt)==w then
	    a=""
	  else
	    a=string.sub(video[img][pos.y], pos.x+string.len(txt), -1)
	  end
	  video[img][pos.y]=t..txt..a
	  if pos.x+string.len(txt)>(w) then pos.x=(w) else
	  pos.x=pos.x+string.len(txt) end
  end
  isFaked=true
end


-- PART III FRAMES FUNCTIONS
function getFree(tabl)
local i=1
while tabl[i]~=nil do
 i=i+1
end
return i
end


function setTitle(txt)
shared.needupdate=true
 p[q].title=txt
end
function setLongTitle(txt)
 p[q].longtitle=txt
end

function newWindow(funcy)
shared.needupdate=true
local i = getFree(p)
p[i] = {}
p[i].random = math.random()
p[i].pos={}
p[i].pos.x=1
p[i].pos.y=1
local wt,ht = realw,realh-2
p[i].h = ht
p[i].w = wt
p[i].b=false
p[i].title="Prog "..i
p[i].longtitle="auto"
p[i].hadrun = false
p[i].living = true
 if funcy==nil then
  funcy=files.craftshell
 end
p[i].boot = funcy
video[i]={}
 for n=1, p[i].h do
  video[i][n]=string.rep(" ", p[i].w)
end
p[i].co = coroutine.create(p[i].boot)
os.queueEvent("window_opened",i)
return i
end

--HERE IT IS!

files.update = function()
setTitle("Frames Update")
print("Your version:      "..version)
if type(http)=="table" then
setTitle("Http:")
local ha = http.get(shared.updateurl)
if type(ha)=="table" then
print("Newest version:    "..ha:readAll())
else
print("Could not reach the update server")
end
else
print("HTTP API is not enabled. Could not check for newest version. Type 'help http' to find out how to enable it.")
end
setTitle("Frames Update")
print(" ")
print("Frames Update doesnt support downloading yet..")
print("You can go to the ComputerCraft forums to download the newest version manually")
print("Press enter to close")
while true do
      local a,b = os.pullEvent()
      if a=="key" and b==28 then
       break
      end
     end

end -- end


files.menustart = function()
 local wi,hi = term.getSize()
 function cprint(te)
  print(string.rep(" ",math.floor((wi-#te)/2))..te)
 end
 setTitle("Start")
 setLongTitle("Menu Start - "..version)
 while true do
  term.clear()
  term.setCursorPos(w-11,h)
  term.write("Made by Jan")

  term.setCursorPos(1,1)
  cprint("Welcome to "..version)
  if realh<15 then
  cprint("    __________")
  cprint("   /    /    /")
  cprint("  /____/____/ ")
  cprint(" /    /    /  ")
  cprint("/____/____/   ")
  else
  cprint("      ____________")
  cprint("     /     /     /")
  cprint("    /     /     / ")
  cprint("   /_____/_____/  ")
  cprint("  /     /     /   ")
  cprint(" /     /     /    ")
  cprint("/_____/_____/     ")
  end
  print("Type 'tut' for tutorial, 'help' for commands.")
  print("Type nothing to open new window")
  term.write("> ")
  dothis=read()
  if dothis=="tut" then
   focus = newWindow(function()
   setTitle("Tut")
   setLongTitle("Tutorial")
   print("Welcome to Frames!")
   print("See that bar below? That is the taskbar!")
   print("In Frames, you can run multiple programs at the same time")
   print("Press ENTER to open a new shell window!")
   while true do
   local a,b = os.pullEvent()
    if a=="key" and b==28 then
     print(" ")
     print("Good. Do you see a item in the taskbar below?")
     print("You can go yo that window by pressing the TAB key on your keyboard. Press TAB Now!")
     print("Press ENTER to close this window...")
     newWindow()
     os.queueEvent("hai")
     while true do
      local a,b = os.pullEvent()
      if a=="key" and b==28 then
       break
      end
     end
     break
    end
   end
   end)
  elseif dothis=="" then
   focus=newWindow()
  elseif dothis=="help" then
   focus = newWindow(function()
   setTitle("Help")
   print(version.." by Jan")
   print("Special thanks to Ardera, who made Screen Capture")
   print("Command list:")
   print("(nothing)    Open new window")
   print("tut          Start tutorial")
			print("update       Check for updates")
   print("help         Display this window")
   print("mods         List installed mods")
   print("exit (shell) Close window")
   print("exit (menu)  Shutdown computer")
   print("reboot       Reboot computer")
   print(" ")
   print("Press ENTER to close this window...")
   while true do
    local a,b = os.pullEvent()
    if a=="key" and b==28 then
     break
    end
   end
   end)
   os.queueEvent("hai")
  elseif dothis=="exit" then
   os.shutdown()
  elseif dothis=="reboot" then
   os.reboot()
		elseif dothis=="update" then
		 focus = newWindow(files.update)
  elseif dothis=="mods" then
   focus=newWindow(function()
    setTitle("Mods")
    print("The following mods are installed: ")
    for a,b in pairs(mods) do
     print(b.name.." / ".. b.vers)
     print("     by: "..b.dev)
    end
    while true do
     local a,b = os.pullEvent()
     if a=="key" and b==28 then
      break
     end
    end
   end
   )

  end
 end
end

files.craftshell = function(...)
local parentShell = shell

local bExit = false
local sDir = (parentShell and parentShell.dir()) or ""
local sPath = (parentShell and parentShell.path()) or ".:/rom/programs"
local tAliases = (parentShell and parentShell.aliases()) or {}
local tProgramStack = {}

local shell = {}
local tEnv = {
	["shell"] = shell,
}
if q>9 then
setTitle("Shell"..q)
setLongTitle("Shell "..q)
else
setTitle("Shell "..q)
end
-- Install shell API
function shell.run( _sCommand, ... )
 setLongTitle(_sCommand)
 setTitle(_sCommand)
	local sPath = shell.resolveProgram( _sCommand )
	if sPath ~= nil then
		tProgramStack[#tProgramStack + 1] = sPath
   		local result = os.run( tEnv, sPath, ... )
      setLongTitle("auto")
 setTitle("Shell "..q)
		tProgramStack[#tProgramStack] = nil
		return result
   	else
    	print( "No such program" )
    	return false
    end
end


function shell.exit()
    bExit = true
end

function shell.dir()
	return sDir
end

function shell.setDir( _sDir )
	sDir = _sDir
end

function shell.path()
	return sPath
end

function shell.setPath( _sPath )
	sPath = _sPath
end

function shell.resolve( _sPath )
	local sStartChar = string.sub( _sPath, 1, 1 )
	if sStartChar == "/" or sStartChar == "\\" then
		return fs.combine( "", _sPath )
	else
		return fs.combine( sDir, _sPath )
	end
end

function shell.resolveProgram( _sCommand )
	-- Substitute aliases firsts
	if tAliases[ _sCommand ] ~= nil then
		_sCommand = tAliases[ _sCommand ]
	end

    -- If the path is a global path, use it directly
    local sStartChar = string.sub( _sCommand, 1, 1 )
    if sStartChar == "/" or sStartChar == "\\" then
    	local sPath = fs.combine( "", _sCommand )
    	if fs.exists( sPath ) and not fs.isDir( sPath ) then
			return sPath
    	end
		return nil
    end

 	-- Otherwise, look on the path variable
    for sPath in string.gmatch(sPath, "[^:]+") do
    	sPath = fs.combine( shell.resolve( sPath ), _sCommand )
    	if fs.exists( sPath ) and not fs.isDir( sPath ) then
			return sPath
    	end
    end

	-- Not found
	return nil
end

function shell.programs( _bIncludeHidden )
	local tItems = {}

	-- Add programs from the path
    for sPath in string.gmatch(sPath, "[^:]+") do
    	sPath = shell.resolve( sPath )
		if fs.isDir( sPath ) then
			local tList = fs.list( sPath )
			for n,sFile in pairs( tList ) do
				if not fs.isDir( fs.combine( sPath, sFile ) ) and
				   (_bIncludeHidden or string.sub( sFile, 1, 1 ) ~= ".") then
					tItems[ sFile ] = true
				end
			end
		end
    end

	-- Sort and return
	local tItemList = {}
	for sItem, b in pairs( tItems ) do
		table.insert( tItemList, sItem )
	end
	table.sort( tItemList )
	return tItemList
end

function shell.getRunningProgram()
	if #tProgramStack > 0 then
		return tProgramStack[#tProgramStack]
	end
	return nil
end

function shell.setAlias( _sCommand, _sProgram )
	tAliases[ _sCommand ] = _sProgram
end

function shell.clearAlias( _sCommand )
	tAliases[ _sCommand ] = nil
end

function shell.aliases()
	-- Add aliases
	local tCopy = {}
	for sAlias, sCommand in pairs( tAliases ) do
		tCopy[sAlias] = sCommand
	end
	return tCopy
end

print( os.version() )

-- If this is the toplevel shell, run the startup programs
if parentShell == nil then
	-- Run the startup from the ROM first
	local sRomStartup = shell.resolveProgram( "/rom/startup" )
	if sRomStartup then
		shell.run( sRomStartup )
	end

	-- Then run the user created startup, from the disks or the root
	local sUserStartup = shell.resolveProgram( "/startup" )
	for n,sSide in pairs( redstone.getSides() ) do
		if disk.isPresent( sSide ) and disk.hasData( sSide ) then
			local sDiskStartup = shell.resolveProgram( fs.combine(disk.getMountPath( sSide ), "startup") )
			if sDiskStartup then
				sUserStartup = sDiskStartup
				break
			end
		end
	end

	if sUserStartup then
	  local cancelTime=5
	  os.startTimer(1)
	  while true do
	   term.clear()
	   term.setCursorPos(1,1)
	   print("Press a key to cancel startup ("..cancelTime..")")
	   print("> ")
		 a,b = os.pullEventRaw()
		 if a=="key" then
		  term.clear()
		  term.setCursorPos(1,1)
	   print( os.version() )
		  break
		 elseif a=="timer" then
		  cancelTime=cancelTime-1
		  if cancelTime==0 then
		   term.clear()
		   term.setCursorPos(1,1)
		   print( os.version() )
		   shell.run( sUserStartup )
		   break
		  else
		   os.startTimer(1)
		  end
		 end
		end
	end
 return "stopme"
end

-- Run any programs passed in as arguments
local tArgs = { ... }
if #tArgs > 0 then
	shell.run( ... )
end

-- Read commands and execute them
local tCommandHistory = {}
while not bExit do
	write( shell.dir() .. "> " )

	local sLine = read( nil, tCommandHistory )
	table.insert( tCommandHistory, sLine )

	local tWords = {}
	for match in string.gmatch(sLine, "[^ \t]+") do
		table.insert( tWords, match )
	end

	local sCommand = tWords[1]
	if sCommand then
		shell.run( sCommand, unpack( tWords, 2 ) )
	end
end
end







function newHook(where,hook)
 if hooks[where]==nil then
  hooks[where]={}
  hooknames[where]={}
 end
 local i = getFree(hooks[where])
 hooks[where][i]=hook
 hooknames[where][i]=currentmod
end
function newMod(name,vers,dev,func)
 local i=getFree(mods)
 mods[i]={}
 mods[i].name=name
 mods[i].vers=vers
 mods[i].dev=dev
 mods[i].func=func
 currentmod=name
 mods[i].func()
end

function checkHooks(name)
 fw=true
 for a,b in ipairs(hooks[name]) do
  b()
 end
 return fw
end



-- PART IV THE MODDING PART. INSERT MODS HERE

-- PART IV A: THE SuperPreProcessor: Executes for each os.pullEventRaw()

-- HERE IS A TEMPLATE. USE IT TO MAKE YOUR OWN PREPROCESSORS


-- PART IV B: THE EventPreProcessor: Executes for each time a window gets updated.







-- PART V THE SETUP




-- PART VI THE LOOP

function mainloop()
while true do
 rarg = pack(os.pullEventRaw())
 if checkHooks("spp") then
  for x in pairs(p) do
   q=x
   if p[q].living then
    larg=rarg
    if checkHooks("cpp") then
     lresult=pack(coroutine.resume(p[q].co,unpack(larg)))
    end
    checkHooks("cap")
   end
  end
 end
 checkHooks("sap")
end
end

function startwin()
fakeIt()
checkHooks("preloop")
os.queueEvent("frames_just_started")
mainloop()
end

]]

defaultmods=[[

-- Here come all the Mods.

newMod("Default Mods","v1","Frames", function()

newHook("spp",function()
 if rarg[1]=="key" and rarg[2]==15 then
		shared.needupdate=true
  if focus==#p then
   focus=1
  else
   focus=focus+1
   while true do
   if p[focus]==nil then
     focus=1
    else
     if p[focus].living then
      break
     else
      focus=focus+1
     end
    end
   end
  end
  -- Hehe
 end
end)

newHook("cpp",function()
 if (rarg[1]=="key" or rarg[1]=="char") and focus~=q then
  fw=false
 end
end)

-- VIRTUALISATION

newHook("cpp",function()
 img=q
 w=p[q].w
 h=p[q].h
 pos.x=p[q].pos.x
 pos.y=p[q].pos.y
end)

newHook("cap",function()
 p[q].w=w
 p[q].h=h
 p[q].pos.x=pos.x
 p[q].pos.y=pos.y
end)

 -- PROCESS STARTER AND STOPPER

newHook("cpp",function()
if fw then
 if p[q].hadrun==false then
  larg={}
  p[q].hadrun=true
		shared.needupdate=true
 end
end
end)

newHook("cap",function()

 if lresult[1]==false then
  if type(lresult[2])=="string" then
   errr=lresult[2]
		end
 end

end)


newHook("cap",function()

 if coroutine.status(p[q].co)=="dead" or ( rarg[1]=="key" and rarg[2]==62 and focus==q and focus>1) then
  if focus==q then
		 shared.needupdate=true
   focus=1
  end
  p[q].co=nil
  p[q].living=false
 end

end)


-- RENDERING


newHook("spp",function()
if rarg[1]=="timer" then
 if rarg[2]==shared.num then
   shared.render=true
 end
end

end)

newHook("sap",function()
 if isFaked and shared.render and (shared.forceupdate or shared.needupdate) then
	 shared.needupdate=false
	 shared.livings=0
		for a,b in ipairs(p) do
		 if b.living then
			 shared.livings=shared.livings+1
			end
		end
		shared.tasksize = shared.maxtasksize
  repeat
		shared.tasksize=shared.tasksize-1
		until ((shared.livings-1)*shared.tasksize)+2<realw


  shared.num=os.startTimer(shared.limiter)
  shared.render=false
  u.term.clear()
  u.term.setCursorBlink(true)
  for n=1, #video[focus] do
   u.term.setCursorPos(1, n)
   u.term.write(video[focus][n])
  end
  u.term.setCursorPos(1,realh-1)
  u.term.write(string.rep("_",realw))
  u.term.setCursorPos(1,realh)
  u.term.write("|")
  local ofs=0
  for a,b in ipairs(p) do
   if a==1 then
    if a==focus then
     u.term.setCursorPos(1,realh-1)
     u.term.write("+-+")
    end
    u.term.setCursorPos(1,realh)
    u.term.write("|#|")
				shared.updates=shared.updates+1
   else
    if b.living then
     if a==focus then
      u.term.setCursorPos((ofs*shared.tasksize)+3,realh-1)
      u.term.write("+"..string.rep("-",shared.tasksize-1).."+")
     end
     u.term.setCursorPos((ofs*shared.tasksize)+4,realh)
     u.term.write(b.title:sub(1,(shared.tasksize-1)))
     u.term.setCursorPos(((ofs+1)*shared.tasksize)+3,realh)
     u.term.write("|")
     ofs=ofs+1
    end
   end
  end
  u.term.setCursorPos(p[focus].pos.x,p[focus].pos.y)
 end
end)

-- STARTLOADER

newHook("preloop",function()
newWindow(files.menustart)
--hook end
end)
-- modend
end)



-- Your own mods here please:


]]
assembleit()

