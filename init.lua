local AceAddon = LibStub("AceAddon-3.0");
local NAME_PLATE_LIB = LibStub("LibNameplate-1.0");
local CallbackHandler = LibStub("CallbackHandler-1.0");

--------------------------------------------------------------------------------

local addon = AceAddon:NewAddon("PlayerInfo", "AceConsole-3.0");
addon.Utils = {};
addon.path = "Interface\\Addons\\PlayerInfo";
addon.logLevel = LOGLEVEL;
addon.OnModuleCreated = function(self, module) module.logLevel = -1 end;
addon.callbacks = CallbackHandler:New(addon);


NAME_PLATE_LIB.RegisterCallback(addon, "LibNameplate_NewNameplate", function(event, ...) addon:OnNameplateCreated(...) end)
NAME_PLATE_LIB.RegisterCallback(addon, "LibNameplate_FoundGUID", function(event, ...) addon:OnNameplateDiscoveredGuid(...) end )
NAME_PLATE_LIB.RegisterCallback(addon, "LibNameplate_RecycleNameplate", function(event, ...) addon:OnNameplateRecycled(...) end )

function addon:IterateIfAndDo(list1, list2, func)
   for i = 1, #(list1) do
      func(list1[i], list2[i], i);
   end
end

function addon:OnNameplateCreated(nameplate)
   addon:AddTheFuckingMark(nameplate)
   addon:IterateIfAndDo(addon.playerlistFrames,
                        addon.playerlist,
                        function(f, player, i)
                           if f ~= nil and player ~= nil and player.name ~= nil then
                              local index = string.find(player.name, "-");
                              local nameWithoutRealm = index ~= nil and string.sub(player.name, 1, index-1) or player.name

                              if string.lower(nameWithoutRealm) == string.lower(NAME_PLATE_LIB:GetName(nameplate)) then
                                 addon.Utils.Tools:RunSlashCommand("/scan", "test "..nameWithoutRealm);
                              end
                           end
                        end
   );
end

function addon:OnNameplateDiscoveredGuid(nameplate)
   addon:AddTheFuckingMark(nameplate)
end

function addon:OnNameplateRecycled(nameplate)
   local iconFrame = addon.Utils.ClassIcon:GetNameplateFrame(nameplate);
   if iconFrame ~= nil then
      --print("remove icon for "..NAME_PLATE_LIB:GetName(nameplate))
      iconFrame:Clear();
   end
end

function addon:AddTheFuckingMark(nameplate)
   local nameplateName = NAME_PLATE_LIB:GetName(nameplate);

   for i = 1, 40 do
      local f = addon.playerlistFrames[i];
      local player = addon.playerlist[i];

      if f ~= nil and player ~= nil and player.name ~= nil then
         local index = string.find(player.name, "-");

         -- LUA ternary operator: <variable> = <condition> and <expression_true> or <expression_false>
         local nameWithoutRealm = index ~= nil and string.sub(player.name, 1, index-1) or player.name

         if string.lower(nameWithoutRealm) == string.lower(nameplateName) then
            --print("creating icon for "..nameWithoutRealm)
            player.icon = addon.Utils.ClassIcon:GetOrCreateNameplateIconFrame(nameplate)
            player.icon:SetMetadata({ isPlayer = true })
            player.icon:UpdateAppearence({ ShowPlusIcon = true, OffsetX=0, OffsetY=0 })
         end
      end
   end

   for i = 1, #(addon.friendlist) do
      local player = addon.friendlist[i];
      if string.lower(player.name) == string.lower(nameplateName) then
         player.icon = addon.Utils.ClassIcon:GetOrCreateNameplateIconFrame(nameplate)
         player.icon:SetMetadata({ isPlayer = true })
         player.icon:UpdateAppearence({ ShowPlusIcon = true, OffsetX=0, OffsetY=0 })
      end
   end
end
