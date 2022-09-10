local PlayerInfo = select( 2, ... );
local MainWindow = {};

PlayerInfo.MainWindow = MainWindow;
PlayerInfo.MainWindow.__index = PlayerInfo.MainWindow;    -- Set the __index parameter to reference MainWindow

--[[ CreateFrame(type, global-name, parent-container, template)
   type: Frame, ScrollFrame, ....
   global-name: can be used to reference the frame by: getblobal("name") OR _G["name"]
   parent-container: parent frame
   template: i.e. "UIPanelScrollFrameTemplate"

   working example: local base = CreateFrame("Frame", nil, UIParent);
--]]

function PlayerInfo.MainWindow:Create(framename, parent, w, h)
   local self = {};
   setmetatable(self, PlayerInfo.MainWindow);

   self.frame = CreateFrame("Frame", nil, UIParent); --, "SecureActionButtonTemplate, SecureHandlerShowHideTemplate");
   self.frame:SetPoint("CENTER");
   self.frame:SetSize(w, h);
   self.frame:SetMovable(true);
   self.frame:EnableMouse(true);
   self.frame:SetBackdrop({ bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
                            edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
                            insets = { left = 0, right = 0, top = 0, bottom = 0 },
                            title =  true,
                            titleEdge = false,
                            titleSize = 0,
                            edgeSize = 20 });

   local scrollframe = self:CreateScrollFrame(framename, w, h);
   self.container = self:CreateContainer(scrollframe);

   self.frame:SetScript("OnMouseDown",
                        function (self, button)
                           if button=='LeftButton' then
                              self:StartMoving();
                           end
                        end
   );

   self.frame:SetScript("OnMouseUp",
                        function (self, button)
                           self:StopMovingOrSizing();
                        end
   );

   scrollframe:SetScript("OnVerticalScroll",
                         function(self, offset)
                            -- print("update scroll: "..offset);
                         end
   );

   return self;
end

--PlayerInfo_SCrollFrame
function PlayerInfo.MainWindow:CreateScrollFrame(framename, w, h)
   --local scrollframe = CreateFrame("ScrollFrame", nil, self.frame, "UIPanelScrollFrameTemplate")
   local scrollframe = CreateFrame("ScrollFrame", framename, self.frame, "UIPanelScrollFrameTemplate");
   self.scrollframe = scrollframe; -- debug
   scrollframe:SetSize(w - 39, h - 45);
   scrollframe:SetPoint("TOPLEFT", 10, -35);
   scrollframe:SetFrameStrata("DIALOG");
   --scrollframe:SetMovable(true);
   --scrollframe:EnableMouse(true);
   --scrollframe:SetClampedToScreen(true);

   --debug
   --scrollframe:SetBackdrop({ bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
   --                          --edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
   --                          --insets = { left = 4, right = 4, top = -4, bottom = -4 },
   --                          title =  true,
   --                          titleEdge = false,
   --                          titleSize = 0,
   --                          edgeSize = 0 });
   --scrollframe:SetBackdropColor(1, 0, 1, .5); -- debug

   -- Reset scroll bar, up/down buttons positions
   --[[
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
   --]]

   return scrollframe;
end

function PlayerInfo.MainWindow:CreateContainer(scrollframe)
   --------------------------------------------------------------------------------
   --[[ Implementation 1:
      1) Create a container Frame with 3x height of scroll frame
      2) initialize 40 sub frame, each holds a tex frame of FontString
      3) when updatePlayerInfo is called, the sub frame of corresponding index will be updated with
      f.tex:SetText
   --]]
   --------------------------------------------------------------------------------
   --local fc = CreateFrame("Button", nil, scrollframe); -- debug
   local fc = CreateFrame("Frame", nil, scrollframe);
   self.fc = fc; -- debug
   fc:SetSize(scrollframe:GetWidth(), (scrollframe:GetHeight() * 3));
   fc:SetPoint("TOPLEFT", 0, 0);
   scrollframe:SetScrollChild(fc);

   --debug -- require CreateFrame("Button", nil, scrollframe);
   --fc:SetNormalTexture( [[Interface\AchievementFrame\UI-Achievement-Parchment-Horizontal]] );
   --local Background = fc:GetNormalTexture();
   --Background:SetDrawLayer( "BACKGROUND" );
   --Background:ClearAllPoints();
   --Background:SetPoint( "BOTTOMLEFT", 3, 3 );
   --Background:SetPoint( "TOPRIGHT", -3, -3 );
   --Background:SetTexCoord( 0, 1, 0, 0.25 );

   --debug
   --fc:SetBackdrop({ bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
   --                 --edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
   --                 --insets = { left = 4, right = 4, top = -4, bottom = -4 },
   --                 title =  true,
   --                 titleEdge = false,
   --                 titleSize = 0,
   --                 edgeSize = 0 });
   --fc:SetBackdropColor(0, 1, 0, 0.5); -- debug



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
   return fc;
end

function PlayerInfo.MainWindow:AddButton(title, point, func)
   print(title);
   print(point);

   local btn = CreateFrame("Button", nil, self.frame, "UIPanelButtonTemplate");
   btn:SetPoint(point.point, point.xOfs, point.yOfs); -- "TOPRIGHT", -10, -10);
   btn:SetSize(100, 25);
   btn:SetText(title);
   btn:RegisterForClicks("AnyUp");
   btn:SetScript("OnClick",
                 function(self, button, down)
                    func();
                 end
   );
end
