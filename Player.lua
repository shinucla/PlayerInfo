local PlayerInfo = select( 2, ... );
local Player = {};
Player.__index = Player; -- use __index to fix "attempt to index global 'Player' (a nil value)" error
PlayerInfo.Player = Player;

-- name, faction, talen, lastUpdated, honorkills, rank
-- rank: heal/dps rank position from GetBattlefieldScore
function Player:new(uiparent, name, faction, talent, honorkills, rank, lastUpdated)
   local self = {};
   setmetatable(self, self);
   self.__index = self; -- use __index to fix "attempt to index global 'Player' (a nil value)" error

   self.name = name;
   self.faction = faction;
   self.talent = talent;
   self.honorkills = honorkills;
   self.rank = rank;
   self.lastUpdated = lastUpdated;

   local f = CreateFrame( "Button", nil, uiparent, "SecureActionButtonTemplate,SecureHandlerShowHideTemplate" );
   f:SetAttribute("unit", "player");
   f:SetAttribute("toggleForVehicle", true);
   f:RegisterForClicks("AnyUp")
   f:SetAttribute("type1", "macro") -- left click to run macro
   f:SetAttribute("type2", "spell") -- [togglemenu, spell] - Toggle units menu on right click

   f:SetSize(200, 50);
   f:SetBackdropColor(1, 0, 0, 1);
   --f:Hide();

   f.tex = f:CreateFontString(nil, "ARTWORK");
   f.tex:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE");
   f.tex:SetPoint("LEFT", 2, 0); -- place fontstring on [LEFT] of button's [RIGHT]
   --f.tex:SetPoint("LEFT", f.button, "RIGHT", 2, 0); -- place fontstring on [LEFT] of button's [RIGHT]
   f.tex:SetJustifyH("LEFT");
   f.tex:SetText("Unknow");
   f.tex:SetTextColor(1, 1, 1, 0.5);

   f:SetPoint("CENTER") -- CENTER
   f:SetSize(100, 100)
   f:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8" })
   f:SetBackdropColor(0.3, 0.3, 0.3, 0.8)

   self.frame = f;

   return self;
end

return Player;
