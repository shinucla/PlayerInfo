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

--local arrow1 = _G["PlayerInfo_Arrow"]:new();
--local arrow2 = _G["PlayerInfo_Arrow"]:new();
--local arrow3 = _G["PlayerInfo_Arrow"]:new();
local arrow1 = PlayerInfo.GpsArrow:new();
local arrow2 = PlayerInfo.GpsArrow:new();
local arrow3 = PlayerInfo.GpsArrow:new();


--local player1 = Player:new(UIParent, "Blk", 1, "Blood", 123, 1, 1234);
--player1.frame:Show();

--local player2 = Player:new(UIParent, "Blk", 1, "Blood", 123, 1, 1234);
--player2.frame:Show();

--[[ Features
   1) Check and list talent with honor kills
   2) Assign raid icons for heals
   3) Mouse over adding talen and honor kills info
   4) Arrow pointing for focused teammate
--]]

--[[ CreateFrame(type, global-name, parent-container, template)
   type: Frame, ScrollFrame, ....
   global-name: can be used to reference the frame by: getblobal("name") OR _G["name"]
   parent-container: parent frame
   template: i.e. "UIPanelScrollFrameTemplate"

   working example: local base = CreateFrame("Frame", nil, UIParent);
--]]

--local smf = CreateFrame("ScrollingMessageFrame", nil, UIParent );
--smf:SetWidth(200);
--smf:SetHeight(150);
--smf:SetFrameStrata("FULLSCREEN_DIALOG");
--smf:SetJustifyH("LEFT");
--smf:SetFading(false);
--smf:SetInsertMode("BOTTOM");
--smf:SetFontObject("GameFontNormal");
--smf:SetMaxLines(200);
--smf:EnableMouse(true);
--smf:EnableMouseWheel(1);
--smf:SetPoint("CENTER", 0, 0);
--smf:SetBackdrop({
--      bgFile = "Interface\\ChatFrame\\ChatFrameBackground", --black, opaque background
--      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
--      tile = true,
--      tileSize = 32,
--      edgeSize = 32,
--      insets = { left = 8, right = 8, top = 8, bottom = 8 } -- see wow.gamepedia
--});
--smf:SetBackdropColor(0, 0, 0, 1);
--smf:Show();
--
--smf:AddMessage("Fuck");
--smf:AddMessage("Shit", 1,0,0);


--[[ Use
--]]


--------------------------------------------------------------------------------

function playerlist:OnInitialize()
   CharacterEnemyNameDB = CharacterEnemyNameDB or {};
   CharacterEnemyNameDB.heal = CharacterEnemyNameDB.heal or {};
   CharacterEnemyNameDB.dps = CharacterEnemyNameDB.dps or {};

   self.db = CharacterEnemyNameDB;
end

--------------------------------------------------------------------------------

local mainframe = CreateFrame("Frame", nil, UIParent);
mainframe:SetPoint("CENTER");
mainframe:SetSize(400, 250);
mainframe:SetMovable(true);
mainframe:EnableMouse(true);
mainframe:SetBackdrop({ bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
                        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
                        insets = { left = 0, right = 0, top = 0, bottom = 0 },
                        title =  true,
                        titleEdge = false,
                        titleSize = 0,
                        edgeSize = 20 });

--------------------------------------------------------------------------------

local btnCheckTalent = CreateFrame("Button", nil, mainframe, "UIPanelButtonTemplate");
btnCheckTalent:SetPoint("TOPRIGHT", -10, -10);
btnCheckTalent:SetSize(100, 25);
btnCheckTalent:SetText("Check Talent");
btnCheckTalent:RegisterForClicks("AnyUp");

btnCheckTalent:SetScript("OnClick",
                         function(self, button, down)
                            doCheckTalent();
                         end
);

local btnCheckBgStats = CreateFrame("Button", nil, mainframe, "UIPanelButtonTemplate");
btnCheckBgStats:SetPoint("TOPRIGHT", -110, -10);
btnCheckBgStats:SetSize(120, 25);
btnCheckBgStats:SetText("Check bg stats");
btnCheckBgStats:RegisterForClicks("AnyUp");

btnCheckBgStats:SetScript("OnClick",
                         function(self, button, down)
                            doCheckBgStats();
                         end
);

--------------------------------------------------------------------------------

local scrollframe = CreateFrame("ScrollFrame", "PlayerInfo_SCrollFrame", mainframe, "UIPanelScrollFrameTemplate");
scrollframe:SetPoint("BOTTOM", 0, 10);
scrollframe:SetFrameStrata("DIALOG");
scrollframe:SetSize(400, 200);
--scrollframe:SetMovable(true);
--scrollframe:EnableMouse(true);
--scrollframe:SetClampedToScreen(true);
--scrollframe:SetBackdrop({ bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
--                          --edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
--                          --insets = { left = 4, right = 4, top = -4, bottom = -4 },
--                          title =  true,
--                          titleEdge = false,
--                          titleSize = 0,
--                          edgeSize = 0 });
--scrollframe:SetBackdropColor(1, 0, 1, .5);

-- Reset scroll bar, up/down buttons positions
local scrollFrameName = scrollframe:GetName()
local scrollbar = _G[scrollFrameName.."ScrollBar"];
local scrollupbutton = _G[scrollFrameName.."ScrollBarScrollUpButton"];
local scrolldownbutton = _G[scrollFrameName.."ScrollBarScrollDownButton"];
scrollbar:ClearAllPoints();
scrollupbutton:ClearAllPoints();
scrolldownbutton:ClearAllPoints();
scrollbar:SetPoint("TOP", scrollupbutton, "BOTTOM", 0, 0);    -- 0, -4
scrollbar:SetPoint("BOTTOM", scrolldownbutton, "TOP", 0, 0);  -- 0,  4
scrollupbutton:SetPoint("TOPRIGHT", scrollframe, "TOPRIGHT", -8, -4);
scrolldownbutton:SetPoint("BOTTOMRIGHT", scrollframe, "BOTTOMRIGHT", -8, 2);

--------------------------------------------------------------------------------
--[[ Implementation 1:
   1) Create a container Frame with 3x height of scroll frame
   2) initialize 40 sub frame, each holds a tex frame of FontString
   3) when updatePlayerInfo is called, the sub frame of corresponding index will be updated with
   f.tex:SetText
--]]
--------------------------------------------------------------------------------
local fc = CreateFrame("Frame", nil, scrollframe);
--local p2 = PlayerInfo.Player:new(fc, "Blk", 1, "Blood", 123, 1, 1234);
--p2.frame:Show();
fc:SetSize(scrollframe:GetWidth(), (scrollframe:GetHeight() * 3));
fc:SetPoint("TOPLEFT", scrollframe, "TOPLEFT", 4, 16);
fc:SetPoint("BOTTOMRIGHT", scrollframe, "BOTTOMRIGHT", 4, -16);
scrollframe:SetScrollChild(fc);

--------------------------------------------------------------------------------
--[[ Implementation 2:
   1) Create a container ScrollingMessageFrame with 3x height of scroll frame
   2) when updatePlayerInfo is called, just addMessage(text, r, g, b)
--]]
--------------------------------------------------------------------------------
--local fc = CreateFrame("ScrollingMessageFrame", nil, scrollframe);
--fc:SetSize(scrollframe:GetWidth()-40, (scrollframe:GetHeight() * 3));
--fc:SetPoint("TOPLEFT", scrollframe, "TOPLEFT", 100, 40);
--fc:SetFading(false);
--fc:SetJustifyH("LEFT");
--fc:SetInsertMode("TOP");
--fc:SetFontObject("GameFontNormal");
--fc:SetMaxLines(200);
--fc:Clear();
--scrollframe:SetScrollChild(fc);

--------------------------------------------------------------------------------
-- Scopt Hooks
--------------------------------------------------------------------------------

mainframe:SetScript("OnMouseDown",
                    function (self, button)
                       if button=='LeftButton' then
                          self:StartMoving();
                       end
                    end
);

mainframe:SetScript("OnMouseUp",
                    function (self, button)
                       self:StopMovingOrSizing();
                    end
);

scrollframe:SetScript("OnVerticalScroll",
                      function(self, offset)
                         -- print("update scroll: "..offset);
                      end
);

--------------------------------------------------------------------------------
-- Event Hooks
--------------------------------------------------------------------------------

scrollframe:RegisterEvent("ADDON_LOADED")
scrollframe:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND");
scrollframe:RegisterEvent("PLAYER_FOCUS_CHANGED");
scrollframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
--scrollframe:RegisterEvent("INSPECT_TALENT_READY");

scrollframe:SetScript("OnEvent", function(self, event, ...)
                         local msg, sender = ...;

                         if ("ADDON_LOADED" == event and "PlayerInfo" == msg) then
                            DEFAULT_CHAT_FRAME:AddMessage("Welcome to Player Info", 1,1,0);
                            playerlist:OnInitialize();
                         end

                         if ("PLAYER_ENTERING_BATTLEGROUND" == event) then
                            DEFAULT_CHAT_FRAME:AddMessage("Entering bg", 1,1,0);
                         end

                         -------------------------------------------------------
                         if ("INSPECT_TALENT_READY" == event) then
                            scrollframe:UnregisterEvent("INSPECT_TALENT_READY");

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
                            scrollframe:UnregisterEvent("INSPECT_HONOR_UPDATE");
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
end);


--------------------------------------------------------------------------------
-- functions
--------------------------------------------------------------------------------

function PlayerInfo_OnTooltipSetUnit(self, event, ...)
   local Name = GameTooltip:GetUnit();
   if ( CanInspect("mouseover") ) and ( UnitName("mouseover") == Name ) and not ( GS_PlayerIsInCombat ) then
      NotifyInspect("mouseover");
      inspectTainted = false;
      desiredInspectedName = Name;
      desiredInspectedTarget = "mouseover";
      scrollframe:RegisterEvent("INSPECT_TALENT_READY");

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
      SelectTarget(arg);

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

function SelectTarget(role)
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
      print(CharacterEnemyNameDB[role][i]);
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
                    scrollframe:RegisterEvent("INSPECT_HONOR_UPDATE");
                    scrollframe:RegisterEvent("INSPECT_TALENT_READY");
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
   tinsert(waitTable,{delay,func,{...}});
   return true;
end

function initPlayerListFramesImplementation1(w, h, parent)
   local x = 0;
   local y = 1;

   local pref = nil;
   for i = 1,40 do
      --local f = CreateFrame("Frame", nil, parent);
      local f = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate,SecureHandlerShowHideTemplate")

      -- macro button settup
      f:SetAttribute("unit", "player");
      f:SetAttribute("toggleForVehicle", true);
      f:RegisterForClicks("AnyUp")
      f:SetAttribute("type1", "macro") -- left click to run macro
      f:SetAttribute("type2", "spell") -- [togglemenu, spell] - Toggle units menu on right click
      --f:SetAttribute("macrotext", "/scan test "..role.name);

      if (pref) then
         f:SetPoint("TOP", pref, "BOTTOM");
      else
         f:SetPoint("TOP", 2, y);
      end

      f:SetSize(w, h);
      f:SetBackdropColor(1, 0, 0, 1);
      f:Hide();

      --f.button = CreateFrame("Button", nil, f, "UIPanelButtonTemplate");
      --button:SetPoint("LEFT");
      --button:SetSize(50, h);
      --button:SetText("focus");
      --button:RegisterForClicks("AnyUp");

      f.tex = f:CreateFontString(nil, "ARTWORK");
      f.tex:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE");
      f.tex:SetPoint("LEFT", 2, 0); -- place fontstring on [LEFT] of button's [RIGHT]
      --f.tex:SetPoint("LEFT", f.button, "RIGHT", 2, 0); -- place fontstring on [LEFT] of button's [RIGHT]
      f.tex:SetJustifyH("LEFT");
      f.tex:SetText("Unknow");
      f.tex:SetTextColor(1, 1, 1, 0.5);

      --f:SetScript("OnMouseDown", function(self, button)
      --               print("on mouse click fuk yea");
      --               if (f.player and "LeftButton" == button) then
      --                  f.player:print();
      --               end
      --end)

      y = y + 20;

      table.insert(playerlistFrames, f);
      pref = f;
   end
end

function addToList(name, talent, hk)
   -- table.insert(playerlist, name.." >> "..talent);
   table.insert(playerlist, Character:new(name, talent, hk));
end

-- function updatePlayerInfoImplementation0()
--    if (fc) then
--       --fc.tex = fc:CreateFontString(nil, "ARTWORK");
--       --fc.tex:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE");
--       --fc.tex:SetPoint("TOPLEFT", 20, -8);
--       fc.tex:SetText(table.concat(playerlist, "\n"));
--    end
-- end

function updatePlayerInfoImplementation1(number)
   for i = 1, number do
      local f = playerlistFrames[i];
      local player = playerlist[i];

      if (playerlist[i]) then
         f.player = player;
         f.tex:SetText(player.name.." >> "..player.talent.." (kills: "..player.hk..")");
         f.tex:SetTextColor(player:getColor());
         f:SetAttribute("macrotext", "/cleartarget\n/target "..player.name.."\n/scan test "..player.name)
         f:Show();

      else
         f:Hide();
      end
   end
end

function updatePlayerInfoImplementation2()
   fc:Clear();

   for k, player in pairs(playerlist) do
      fc:AddMessage(player.name.." >> "..player.talent, player:getColor());
   end
end

function PlayerInfo_OnLoad()
   GameTooltip:HookScript("OnTooltipSetUnit", PlayerInfo_OnTooltipSetUnit);

   initPlayerListFramesImplementation1(350, 20, fc); -- implementation 1

   SlashCmdList["PLAYERINFO"] = function(msg)
      PlayerInfo_SlashCommandHandler(msg);
   end
end

--------------------------------------------------------------------------------
-- lua class
--------------------------------------------------------------------------------

Character = {};             -- To create a class, we must make a table
Character.__index = Character;    -- Set the __index parameter to reference Character
function Character:new(name, talent, hk)
   local self = {};               -- Create a blank table
   setmetatable(self, Character); -- Set the metatable so we used Character's __index imbue the class

   self.name = name;
   self.talent = talent;
   self.hk = hk;
   return self;
end

function Character:print(str)
   print(str..self.name.." >> "..self.talent);
end

function Character:getColor()
   if "Restoration" == self.talent or "Holy" == self.talent or "Discipline" == self.talent then
      return 0, 1, 0;

   elseif "Protection" == self.talent or "Frost" == self.talent then
      return 0.2, 0.8, 1;

   else
      return 1, 0.4, 0.6;
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

PlayerInfo_OnLoad()
