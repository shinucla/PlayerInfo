local me = select( 2, ... );
PlayerInfo = me;

SLASH_PLAYERINFO1 = "/playerinfo";
SLASH_PLAYERINFO2 = "/pi";

local playerlist = {};
local playerlistFrames = {};

local inspectTainted = false;
local desiredInspectedName = nil;
local desiredInspectedTarget = nil;
local desiredTooltip = nil;
local target_hk = nil;

local arrow1 = PlayerInfo.GpsArrow:new();
local arrow2 = PlayerInfo.GpsArrow:new();
local arrow3 = PlayerInfo.GpsArrow:new();

local mainWindow = PlayerInfo.MainWindow:Create("main", UIParent, 400, 250);
PlayerInfo.mainWindow = mainWindow;

mainWindow:AddButton("check team",
                     {["point"] = "TOPRIGHT"; ["xOfs"] = -7; ["yOfs"] = -7 },
                     function(self, button, down)
                        doCheckTalent();
                     end
);

mainWindow:AddButton("scan bg",
                     {["point"] = "TOPRIGHT"; ["xOfs"] = -107; ["yOfs"] = -7 },
                     function(self, button, down)
                        ScanBattleground("heal");
                     end
);

mainWindow:AddButton("scan list",
                     {["point"] = "TOPRIGHT"; ["xOfs"] = -207; ["yOfs"] = -7 },
                     function(self, button, down)
                        SearchListForTarget("heal");
                     end
);

--------------------------------------------------------------------------------

--[[ initialize player entry frame list (40 frames) ]]
for i = 1, 40 do
   table.insert(playerlistFrames, PlayerInfo.PlayerFrame:Create(mainWindow.container, 460, 20, i));
end

--------------------------------------------------------------------------------

--[[ Features
   1) Check and list talent with honor kills
   2) Assign raid icons for heals
   3) Mouse over adding talen and honor kills info
   4) Arrow pointing for focused teammate
--]]

function playerlist:OnInitialize()
   CharacterEnemyNameDB = CharacterEnemyNameDB or {};
   CharacterEnemyNameDB.heal = CharacterEnemyNameDB.heal or {};
   CharacterEnemyNameDB.dps = CharacterEnemyNameDB.dps or {};

   self.db = CharacterEnemyNameDB;
end

--------------------------------------------------------------------------------
-- Event Hooks
--------------------------------------------------------------------------------

mainWindow.frame:RegisterEvent("PLAYER_LOGIN");
mainWindow.frame:RegisterEvent("PLAYER_ENTERING_WORLD");
mainWindow.frame:RegisterEvent("ADDON_LOADED")
mainWindow.frame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND");
mainWindow.frame:RegisterEvent("PLAYER_FOCUS_CHANGED");
mainWindow.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
--mainWindow.frame:RegisterEvent("INSPECT_TALENT_READY");

mainWindow.frame:SetScript("OnEvent",
                           function(self, event, ...) -- ... = isLogin, isReload
                              local msg, sender = ...;

                              if ("PLAYER_LOGIN" == event) then
                                 PlayerInfo.LoadLastPoint();
                              end

                              if ("PLAYER_ENTERING_WORLD" == event) then
                                 PlayerInfo.SaveLastPoint();
                              end

                              if ("ADDON_LOADED" == event and "PlayerInfo" == msg) then
                                 DEFAULT_CHAT_FRAME:AddMessage("Welcome to Player Info", 1,1,0);
                                 playerlist:OnInitialize();
                              end

                              if ("PLAYER_ENTERING_BATTLEGROUND" == event) then
                                 DEFAULT_CHAT_FRAME:AddMessage("Entering bg", 1,1,0);
                              end

                              -------------------------------------------------------
                              if ("INSPECT_TALENT_READY" == event) then
                                 mainWindow.frame:UnregisterEvent("INSPECT_TALENT_READY");

                                 --if false == inspectTainted and nil ~= desiredInspectedName then
                                 --   handleOnInspectReady(desiredInspectedName, desiredInspectedTarget)
                                 --   --ClearInspectPlayer();
                                 --   desiredInspectedName = nil
                                 --   desiredInspectedTarget = nil;
                                 --
                                 --elseif (desiredInspectedName) then
                                 --   --ClearInspectPlayer();
                                 --   NotifyInspect(desiredInspectedName);
                                 --   inspectTainted = false;
                                 --end
                              end

                              if ("INSPECT_HONOR_UPDATE" == event) then
                                 mainWindow.frame:UnregisterEvent("INSPECT_HONOR_UPDATE");
                                 --handleOnHonorReady(desiredInspectedName)
                                 --
                                 --
                                 if false == inspectTainted and nil ~= desiredInspectedName then
                                    handleOnInspectReady(desiredInspectedName, desiredInspectedTarget)
                                    --ClearInspectPlayer();
                                    desiredInspectedName = nil
                                    desiredInspectedTarget = nil;

                                 elseif (desiredInspectedName) then
                                    --ClearInspectPlayer();
                                    NotifyInspect(desiredInspectedName);
                                    inspectTainted = false;
                                 end
                                 --
                                 --
                              end
                              -------------------------------------------------------

                              if ("PLAYER_FOCUS_CHANGED" == event) then
                                 arrow1:LoadPosition("BOTTOM", -100, 350);
                                 arrow1:ShowRunTo("focus");

                                 arrow2:LoadPosition("BOTTOM", 0, 350);
                                 arrow2:ShowRunTo("focus");

                                 arrow3:LoadPosition("BOTTOM", 100, 350);
                                 arrow3:ShowRunTo("focus");

                              end

                              if ((UnitName("player") == arg7)
                                 and (arg2 == "SPELL_AURA_APPLIED" or arg2 == "SPELL_AURA_REFRESH")
                                 and (arg9 == 51724 or arg9 == 11297 or arg9 == 2070 or arg9 ==  6770))
                              then
                                 --SendChatMessage("==> Rogue here! <==", "YELL");
                              end
                           end
);


--------------------------------------------------------------------------------
-- functions
--------------------------------------------------------------------------------

function PlayerInfo.LoadLastPoint()
   local option = CharacterEnemyNameDB;

   if (option
       and option.LastPoint
       and option.LastPoint.point
       and option.LastPoint.xOfs
       and option.LastPoint.yOfs) then
      local p, r, rp, xofs, yofs = PlayerInfo.mainWindow.frame:GetPoint();

      if (p ~= option.LastPoint.point
          or xofs ~= option.LastPoint.xOfs
          or yofs ~= option.LastPoint.yOfs) then
         PlayerInfo.mainWindow.frame:SetPoint(option.LastPoint.point,
                                              UIParent,
                                              option.LastPoint.xOfs,
                                              option.LastPoint.yOfs);
      end
   end
end

function PlayerInfo.SaveLastPoint()
   local p, r, rp, xofs, yofs = PlayerInfo.mainWindow.frame:GetPoint();
   CharacterEnemyNameDB.LastPoint = CharacterEnemyNameDB.LastPoint or {};
   CharacterEnemyNameDB.LastPoint.point = CharacterEnemyNameDB.LastPoint.point or p;
   CharacterEnemyNameDB.LastPoint.xOfs  = CharacterEnemyNameDB.LastPoint.xOfs or xofs;
   CharacterEnemyNameDB.LastPoint.yOfs  = CharacterEnemyNameDB.LastPoint.yOfs or yofs;
end

function PlayerInfo_OnTooltipSetUnit(self, event, ...)
   local Name = GameTooltip:GetUnit();
   if ( CanInspect("mouseover") ) and ( UnitName("mouseover") == Name ) and not ( GS_PlayerIsInCombat ) then
      NotifyInspect("mouseover");
      inspectTainted = false;
      desiredInspectedName = Name;
      desiredInspectedTarget = "mouseover";
      mainWindow.frame:RegisterEvent("INSPECT_TALENT_READY");

      wait(0.4, function()
              GameTooltip:AddLine(tostringall(desiredTooltip));
              desiredTooltip = nil;
      end);
   end
end

function PlayerInfo_SlashCommandHandler(msg)
   local cmd, arg = string.split(" ", msg, 2)
   cmd = string.lower(cmd or "")
   arg = string.lower(arg or "")

   if (cmd == "save" and arg ~= "") then
      local role, name = string.split(" ", arg, 2)
      role = string.lower(role or "")
      name = string.lower(name or "")

      SaveEnemy(role, name);

   elseif (cmd == "remove" and arg ~= "") then
      RemoveEnemy(arg);

   elseif (cmd == "scan") then
      ScanBattleground(arg);

   elseif (cmd == "target") then
      SearchListForTarget(arg);

   elseif (cmd == "list") then
      ListEnemyDB(arg);

   else
      listAllPlayerInfo();
   end
end

function SaveEnemy(role, name)
   CharacterEnemyNameDB[role] = CharacterEnemyNameDB[role] or {};

   for i = 1, #(CharacterEnemyNameDB[role]) do
      if (CharacterEnemyNameDB[role][i] == name) then
         return;
      end
   end

   table.insert(CharacterEnemyNameDB[role], name);
end

function RemoveEnemy(name)
   CharacterEnemyNameDB["heal"] = CharacterEnemyNameDB["heal"] or {};
   CharacterEnemyNameDB["dps"] = CharacterEnemyNameDB["dps"] or {};

   for i = 1, #(CharacterEnemyNameDB.heal) do
      if (CharacterEnemyNameDB.heal[i] == name) then
         table.remove(CharacterEnemyNameDB.heal, i);
      end
   end
   for i = 1, #(CharacterEnemyNameDB.dps) do
      if (CharacterEnemyNameDB.dps[i] == name) then
         table.remove(CharacterEnemyNameDB.dps, i);
      end
   end
end

function ScanBattleground(roleName)
   --[[ clear playerlist
      TODO: Change it from global variable to PlayerInfo.playerlist or me.playerlist
      place following code in the first entry lua file (defined in toc)
      -- local me = select( 2, ... );
      -- PlayerInfo = me;
   --]]
   playerlist = {} --
   updatePlayerInfoImplementation1(40);

   --[[ lua array format:
      local array = {{ ["name"]="A" }, { ["name"]="B" }, { ["name"]="C" }};
      array[1] ----> { ["name"]="A" }
      array[2] ----> { ["name"]="B" }
      array[3] ----> { ["name"]="C" }
      array[2].name ----------> "B"

      Top 4 players:
   --]]
   local players = {};
   for i = 1, GetNumBattlefieldScores() do
      local name, killingBlows, honorableKills, deaths, honorGained, faction, unknown, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec = GetBattlefieldScore(i);
      local max = math.max(damageDone, healingDone);
      local value = (roleName == "heal" and healingDone == max and max or (roleName == "dps" and damageDone == max and max or 0));

      if (name ~= nil
          and not UnitIsFriend("player", name)
          and (class=="Priest" or class=="Shaman" or class=="Paladin" or class=="Druid")
          and 10000 < value) then
         table.insert(players,
                      {  ["name"]=name,
                         ["talent"]=(roleName=="heal" and "Holy" or "Blood"),
                         ["faction"]=faction,
                         ["value"]=value });
      end

   end

   if (next(players)) then
      local num = math.min(#(players), 4);
      table.sort(players, function(a, b) return a.value > b.value; end);

      for i = 1, num do
         local player = players[i];

         if (200000 < player.value) then SaveEnemy(roleName, player.name); end
         addToList(player.name, player.talent, player.value);
         DEFAULT_CHAT_FRAME:AddMessage(roleName..(player.faction == 0 and " Horde " or " Ally ")..player.name, 1,1,0);
      end

      updatePlayerInfoImplementation1(num);
   end
end

function SearchListForTarget(role)
   playerlist = {};
   updatePlayerInfoImplementation1(40);

   local num = 0;
   for i = 1, 80 do
      local name = GetBattlefieldScore(i);

      if (name ~= nil) then
         if not (UnitIsFriend("player", name)) then
            for i = 1, #(CharacterEnemyNameDB[role]) do
               if (CharacterEnemyNameDB[role][i] == name) then -- and initTarget == false) then
                  addToList(name, (role == "heal" and "Holy" or "Blood"), 0);
                  DEFAULT_CHAT_FRAME:AddMessage(name, 1,1,0);
                  num = num + 1;
               end
            end
         end
      end
   end

   updatePlayerInfoImplementation1(40);
end

function ListEnemyDB(role)
   playerlist = {};
   updatePlayerInfoImplementation1(40);

   for i = 1, #(CharacterEnemyNameDB[role]) do
      addToList(CharacterEnemyNameDB[role][i], (role == "heal" and "Holy" or "Blood"), 0);
   end

   updatePlayerInfoImplementation1(math.min(#(CharacterEnemyNameDB[role]), 40));
end

function listAllPlayerInfo()
   playerlist = {};
   healmarkIndex = 0;

   local count = 0;

   for i = 1,40 do
      local name, r, sg, l, c, fn,z,o, iD, role, isML, cR = GetRaidRosterInfo(i);

      if (name) then
         if (CanInspect(name)) then
            count = count + 1;
            wait(count * 0.4, function()
                    NotifyInspect(name);        -- will trigger INSPECT_TALENT_READY event and callback on handleOnInspectReady
                    RequestInspectHonorData();  -- will trigger INSPECT_HONOR_UPDATE

                    inspectTainted = false;
                    desiredInspectedName = name;
                    desiredInspectedTarget = "player";
                    mainWindow.frame:RegisterEvent("INSPECT_HONOR_UPDATE");
                    mainWindow.frame:RegisterEvent("INSPECT_TALENT_READY");
            end);
         end
      end
   end

   -- wait((count + 1) * 0.4, function()
   --       updatePlayerInfoImplementation1();
   -- end);
end


local function onBattlegroundDataReady(self, event, ...)
   if event == "UPDATE_BATTLEFIELD_SCORE" then
      self:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE");

      for i=1, 1 do -- GetNumBattlefieldScores() do
         --local playerName = GetBattlefieldScore(i);
         local playerName, killingBlows, honorableKills, deaths, honorGained, faction, unknown, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec = GetBattlefieldScore(i);
         --local flagCaptures = GetBattlefieldStatData(i, 1);
         --local flagReturns = GetBattlefieldStatData(i, 2);
         local a = GetBattlefieldStatData(i, 0);
         local b = GetBattlefieldStatData(i, 1);
         local c = GetBattlefieldStatData(i, 2);
         local d = GetBattlefieldStatData(i, 3);
         local e = GetBattlefieldStatData(i, 4);
         local f = GetBattlefieldStatData(i, 5);
         local g = GetBattlefieldStatData(i, 6);
         print(playerName);
         print(GetBattlefieldStatInfo(0))
         print(a);

         print(GetBattlefieldStatInfo(1))
         print(b);

         print(GetBattlefieldStatInfo(2))
         print(c);

         print(GetBattlefieldStatInfo(3))
         print(d);

         print(GetBattlefieldStatInfo(4))
         print(e);

         print(GetBattlefieldStatInfo(5))
         print(f);

         print(GetBattlefieldStatInfo(6))
         print(g);
      end
   end
end

function doCheckTalent()
   listAllPlayerInfo();
end

function doCheckBgStats()
   ScanBattleground("heal");

   -- Testing ...
   local f = CreateFrame("Frame");
   f:RegisterEvent("UPDATE_BATTLEFIELD_SCORE");
   f:SetScript("OnEvent", onBattlegroundDataReady);
   RequestBattlefieldScoreData();
end

local healmarks = {6, 4, 5, 3, 1};
local healmarkIndex = 0;
function handleOnInspectReady(name, target)
   local talent = getTalent(GetActiveTalentGroup(true, false));

   if (nil == talent) then talent = " -- " end;

   if ("mouseover" == target) then
      if (talent) then
         --GameTooltip:AddLine("Talent: "..talent);
         desiredTooltip = "Talent: "..talent;
      end

   else
      local _,_,_,_,TotalHonorKills = GetInspectHonorData();
      addToList(name, talent, TotalHonorKills);
      updatePlayerInfoImplementation1(40);

      if (IsRaidLeader()) then
         if ("Restoration" == talent or "Holy" == talent or "Discipline" == talent) then
            healmarkIndex = healmarkIndex + 1;

            if (healmarks[healmarkIndex]) then
               SetRaidTarget(name, healmarks[healmarkIndex]);
            end
         end
      end
   end
end

function handleOnHonorReady()
   local _,_,_,_,TotalHonorKills = GetInspectHonorData();
   target_hk = TotalHonorKills;
end

function getTalent(group)
   local maxPoints = 1;
   local maxName;

   for i = 1,3 do
      local name,_,p = GetTalentTabInfo(i, true, false, group);

      if maxPoints <= p then
         maxPoints = p;
         maxName = name;
      end
   end

   return maxName;
end

do
   --all variable are local here
   local waitTable = {};
   local waitFrame = nil;
   function wait(delay, func, ...)
      if(type(delay)~="number" or type(func)~="function") then
         return false;
      end

      if(waitFrame == nil) then
         waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
         waitFrame:SetScript("onUpdate",function (self,elapse)
                                local count = #waitTable;
                                local i = 1;
                                while(i<=count) do
                                   local waitRecord = tremove(waitTable,i);
                                   local d = tremove(waitRecord,1);
                                   local f = tremove(waitRecord,1);
                                   local p = tremove(waitRecord,1);
                                   if(d>elapse) then
                                      tinsert(waitTable,i,{d-elapse,f,p});
                                      i = i + 1;
                                   else
                                      count = count - 1;
                                      f(unpack(p));
                                   end
                                end
         end);
      end

      tinsert(waitTable, {delay, func, {...}});

      return true;
   end
end

function addToList(name, talent, hk)
   table.insert(playerlist, PlayerInfo.Player:new(name, talent, hk));
end

function updatePlayerInfoImplementation1(number)
   for i = 1, number do
      local f = playerlistFrames[i];
      local player = playerlist[i];

      if (playerlist[i]) then
         f:SetText(player.name.." >> "..player.talent.." (kills: "..player.hk..")");
         f:SetColor(player:getColor());
         f:SetMacro("/cleartarget\n/target "..player.name.."\n/scan test "..player.name)
         f:Show();

      else
         f:Hide();
      end
   end
end

function PlayerInfo.OnLoad()
   GameTooltip:HookScript("OnTooltipSetUnit", PlayerInfo_OnTooltipSetUnit);

   SlashCmdList["PLAYERINFO"] = function(msg)
      PlayerInfo_SlashCommandHandler(msg);
   end
end

--------------------------------------------------------------------------------
-- Calling On Load
--------------------------------------------------------------------------------

--[[
   hooksecurefunc once is set, whenever NotifyInspect is called within or outside this addon
   it will trigger hooked function.
--]]
hooksecurefunc("NotifyInspect", function(unit, flag)
                  inspectTainted = true
end);

PlayerInfo.OnLoad()
