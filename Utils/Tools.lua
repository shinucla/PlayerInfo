local AceAddon = LibStub("AceAddon-3.0");
local NAME_PLATE_LIB = LibStub("LibNameplate-1.0");

--------------------------------------------------------------------------------

local addon = AceAddon:GetAddon("PlayerInfo");
local utils = {}

addon.Utils.Tools = utils;

-- command examples: '/scan', '/say', '/recount'....
function utils:RunSlashCommand(command, args)
   for key, func in pairs(SlashCmdList) do
      local i = 1
      local c = _G[("SLASH_%s1"):format(key)]
      while c do
         if c == command then
            func(args)
            return
         end
         i=i+1
         c = _G[("SLASH_%s%d"):format(key,i)]
      end
   end
end
