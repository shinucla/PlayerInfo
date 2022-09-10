local PlayerInfo = select( 2, ... );
local PlayerFrame = {};

PlayerInfo.PlayerFrame = PlayerFrame;
PlayerInfo.PlayerFrame.__index = PlayerInfo.PlayerFrame;    -- Set the __index parameter to reference PlayerFrame

function PlayerInfo.PlayerFrame:Create(parent, w, h, index)
   local self = {};
   setmetatable(self, PlayerInfo.PlayerFrame);

   self.frame = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate,SecureHandlerShowHideTemplate");

   -- macro button settup
   self.frame:SetAttribute("unit", "player");
   self.frame:SetAttribute("toggleForVehicle", true);
   self.frame:RegisterForClicks("AnyUp")
   self.frame:SetAttribute("type1", "macro") -- left click to run macro
   self.frame:SetAttribute("type2", "spell") -- [togglemenu, spell] - Toggle units menu on right click
   --self.frame:SetAttribute("macrotext", "/scan test "..role.name);

   self.frame:SetSize(w, h);
   self.frame:SetPoint("TOPLEFT", 5, -5 - h * (index - 1)); --- TEMP
   self:Hide();

   --debug
   --self.frame:SetBackdrop({ bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
   --                          --edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
   --                          --insets = { left = 4, right = 4, top = -4, bottom = -4 },
   --                          title =  true,
   --                          titleEdge = false,
   --                          titleSize = 0,
   --                          edgeSize = 0 });
   --self.frame:SetBackdropColor(1, 0, 0, .8);

   self.frame.tex = self.frame:CreateFontString(nil, "ARTWORK");
   self.frame.tex:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE");
   self.frame.tex:SetPoint("LEFT", 2, 0); -- place fontstring on [LEFT] of button's [RIGHT]
   --self.frame.tex:SetPoint("LEFT", self.frame.button, "RIGHT", 2, 0); -- place fontstring on [LEFT] of button's [RIGHT]
   self.frame.tex:SetJustifyH("LEFT");
   self.frame.tex:SetText("Unknow");
   self.frame.tex:SetTextColor(1, 1, 1, 0.5);

   return self;
end

function PlayerInfo.PlayerFrame:SetText(value)
   self.frame.tex:SetText(value);
end

function PlayerInfo.PlayerFrame:SetPoint(pos, relative, xofs, yofs)
   self.frame:SetPoint(pos, relative, xofs, yofs);
end

function PlayerInfo.PlayerFrame:Show()
   self.frame:Show();
end

function PlayerInfo.PlayerFrame:Hide()
   self.frame:Hide();
end

function PlayerInfo.PlayerFrame:SetColor(r, g, b)
   self.frame.tex:SetTextColor(r, g, b, opacity);
end

function PlayerInfo.PlayerFrame:SetMacro(macro)
   self.frame:SetAttribute("macrotext", macro);
end
