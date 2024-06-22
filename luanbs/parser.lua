local byte = 1
local short = 2
local int = 4
local str = 999

local Ubyte = 11

local versionFields = {
   [0] = {
      header = {
         {"length", short},
	      {"layer-count", short},
   	   {"name", str},
   	   {"author", str},
   	   {"OG-author", str},
   	   {"description", str},
   	   {"tempo", short},
   	   {"auto-saving", byte},
   	   {"auto-saving-dur", byte},
   	   {"time-signature", byte},
   	   {"minutes-spent", int},
   	   {"leftclick", int},
   	   {"rightclick", int},
   	   {"noteblocks-added", int},
   	   {"noteblocks-removed", int},
   	   {"OG-filename", str},
      },
        
      notes = {
         {"jumps-tick", short},
         {"jumpts-layer", short},
         {"instrument", byte},
         {"key", byte}
      },
        
      layers = {
         {"name", str},
         {"volume", byte}
      },
      instruments = {
         {"name", str},
         {"file", str},
         {"key", byte},
         {"piano", byte}
      }
    },
    [1] = {
        header = {
            [1] = {"classic", short, "replace"},
            [2] = {"NBSversion", byte, "push"},
            [3] = {"vanilla-instrument-count", byte}
        }
    },
    [2] = {
        layers = {
            [3] = {"stereo", Ubyte, "push"}
        }
    },
    [3] = {
        header = {
            [4] = {"length", short, "push"}
        },
        
        layers = {
            [2] = {"lock", byte, "push"},
        },
        
        notes = {
            [5] = {"velocity", byte, "push"},
            [6] = {"panning", byte, "push"},
            [7] = {"pitch", short, "push"}
        }
    },
    [4] = {
        header = {
            [20] = {"loop", byte, "push"},
            [21] = {"loop-count", byte, "push"},
            [22] = {"loop-start", short, "push"}
        }
    },
    [5] = {}
}

function table.len(tbl)
    local x = 0
    for _,_ in pairs(tbl) do x = x + 1 end
    return x 
end

function table.modify(tbl, mods)
    for k, modblock in pairs(mods) do
        local min = 99999
        for i,_ in pairs(modblock) do if i < min then min = i end end
        local len = table.len(modblock)
        for I=1,len do
            local i = min + I - 1
            local mod = modblock[i]
            if mod[3] == "replace" then tbl[k][i] = mod
            else table.insert(tbl[k], i, mod) end
        end
    end
end

function bytesToInt(str, signed)
   local bytes = {}
   for char in str:gmatch(".") do table.insert(bytes, string.byte(char)) end
   
   local multiplier = 1
   local int = 0

   for _, byte in pairs(bytes) do
      int = int + byte * multiplier
      multiplier = multiplier * 256
   end
   
   local max = math.pow(2, #bytes*8-1)
   if int > max and (signed == nil or signed == false) then
        int = int - max*2
    end

   return int
end

function read(file, bytes)
    if bytes == str then
        local str = ""
        local len = file:read(int)
        if len == nil then return nil end
        for _=1,bytesToInt(len) do str = str .. file:read(byte) end
        return str
    elseif bytes ~= Ubyte then
        return bytesToInt(file:read(bytes), false)
    else
        return bytesToInt(file:read(byte), true)
    end
end

function readPart(fields, size, file)
   local part = {}
   
   local block = {}
   for _=1,size do
       for _, field in pairs(fields) do
           block[field[1]] = read(file, field[2])
           if block[field[1]] == nil then return nil end
       end
       table.insert(part, block)
       block = {}
   end
   
   return part
end

function table.copy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = table.copy(v)
		end
		copy[k] = v
	end
	return copy
end

return function(file) 
   local fields = table.copy(versionFields[0])
   
   file = io.open(file, "rb")

   print(file, " pls no nil man")

   local classic = read(file, short)
   
   print(classic)
   
   if classic == 0 then
       local version = read(file, byte)
       print(version)
       for i=1,version do
           table.modify(fields, versionFields[i])
       end
   end 
   
   file:seek("set", 0)

   local data = {header = {}, notes = {}}
   
   -- header
   data.header = readPart(fields.header, 1, file)[1]
   
   -- notes
   local i = 1
   local note = {}
   local b = file:read(short)

   while not (i == 1 and bytesToInt(b) == 0) do
      note[fields.notes[i][1]] = bytesToInt(b)
      
      if i == 1 then for _=1,bytesToInt(b) do table.insert(data.notes, "tick!") end end
      
      if i == 2 and bytesToInt(b) == 0 then 
         i = 1
         table.insert(data.notes, "tick!")
         note = {}
      elseif i == #fields.notes then 
         i = 2
         table.insert(data.notes, note)
         note = {}
      else
         i = i + 1
      end
      
      b = file:read(fields.notes[i][2])
   end
   
   print("layers!")
   data.layers = readPart(fields.layers, data.header["layer-count"], file)

   local instruments = read(file, Ubyte)
   
   if instruments == nil then return data end
   
   data.instruments = readPart(fields.instruments, instruments, file)
   data.instruments.count = instruments
   
   for k, instrument in pairs(data.instruments) do if type(instrument) == "table" then
       print("Substitute for: " .. instrument.name .. " from " .. instrument.file .. ": ")
       data.instruments[k].substitute = _G.read()
   end end
   
   return data
end
