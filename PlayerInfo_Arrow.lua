local PlayerInfo = select( 2, ... );

-- cached variables
local pi, pi2 = math.pi, math.pi * 2
local floor = math.floor
local sin, cos, atan2, sqrt, min = math.sin, math.cos, math.atan2, math.sqrt, math.min
local GetPlayerMapPosition = GetPlayerMapPosition

---------------------
--  Map Utilities  --
---------------------
local SetMapToCurrentZone -- throttled SetMapToCurrentZone function to prevent lag issues with unsupported WorldMap addons
do
   local lastMapUpdate = 0
   function SetMapToCurrentZone(...)
      if GetTime() - lastMapUpdate > 1 then
         lastMapUpdate = GetTime()
         return _G.SetMapToCurrentZone(...)
      end
   end
end

-- -- My new calculateDistance just use scale
local calculateDistance
do
   function calculateDistance(x1, y1, x2, y2)
      local mapName, w, h = GetMapInfo()

      local dX = (x1 - x2) * w
      local dY = (y1 - y2) * h
      return sqrt(dX * dX + dY * dY)
   end
end

-- GetPlayerFacing seems to return values between -pi and pi instead of 0 - 2pi sometimes since 3.3.3
local GetPlayerFacing = function(...)
   local result = GetPlayerFacing(...)
   if result < 0 then
      result = result + pi2
   end
   return result
end


--------------------------------------------------------------------------------
-- class PlayerInfo.GpsArrow
--------------------------------------------------------------------------------

PlayerInfo.GpsArrow = {};
PlayerInfo.GpsArrow.__index = PlayerInfo.GpsArrow;

function PlayerInfo.GpsArrow:new()
   local self = {};                      -- Create a blank table
   setmetatable(self, PlayerInfo.GpsArrow); -- Set the metatable so we used PlayerInfo.GpsArrow's __index imbue the class

   self.targetX = nil;
   self.targetY = nil;
   self.targetPlayer = nil;

   self.currentCell = nil;

   self:initArrow();

   return self;
end

function PlayerInfo.GpsArrow:initArrow()
   -- creating frame that holds arrorw
   self.frame = CreateFrame("Button", nil, UIParent);
   self.frame:Hide()
   self.frame:SetFrameStrata("HIGH")
   self.frame:SetWidth(56)
   self.frame:SetHeight(42)
   self.frame:SetMovable(true)
   self.frame:EnableMouse(false)

   self.arrow = self.frame:CreateTexture(nil, "OVERLAY")
   self.arrow:SetTexture("Interface\\AddOns\\PlayerInfo\\Arrow.blp")
   self.arrow:SetAllPoints(self.frame)

   self.frame:SetScript("OnUpdate", function(theFrame, elapsed)
                           if WorldMapFrame:IsShown() then -- it doesn't work while the world map frame is shown
                              self.arrow:Hide()
                              return
                           end

                           self.arrow:Show()

                           local x, y = GetPlayerMapPosition("player")
                           if x == 0 and y == 0 then
                              SetMapToCurrentZone()
                              x, y = GetPlayerMapPosition("player")
                              if x == 0 and y == 0 then
                                 self.frame:Hide() -- hide the arrow if you enter a zone without a map
                                 return
                              end
                           end

                           if (nil == self.targetPlayer) then
                              self.frame:Hide()
                              return
                           end

                           self.targetX, self.targetY = GetPlayerMapPosition(self.targetPlayer)
                           if self.targetX == 0 and self.targetY == 0 then
                              self.frame:Hide()
                              return
                           end

                           if not self.targetX or not self.targetY then
                              return
                           end

                           local angle = atan2(x - self.targetX, self.targetY - y)
                           if angle <= 0 then -- -pi < angle < pi but we need/want a value between 0 and 2 pi
                              angle = pi - angle -- pi < angle < 2pi

                           else
                              angle = pi - angle  -- 0 < angle < pi
                           end

                           self:updateArrow(angle - GetPlayerFacing(), calculateDistance(x, y, self.targetX, self.targetY))
   end)
end

function PlayerInfo.GpsArrow:updateArrow(direction, distance)
   local cell = floor(direction / pi2 * 108 + 0.5) % 108
   if cell ~= self.currentCell then
      self.currentCell = cell
      local column = cell % 9
      local row = floor(cell / 9)
      local xStart = (column * 56) / 512
      local yStart = (row * 42) / 512
      local xEnd = ((column + 1) * 56) / 512
      local yEnd = ((row + 1) * 42) / 512
      self.arrow:SetTexCoord(xStart, xEnd, yStart, yEnd)
   end

   if distance then
      local perc = min(distance, 100) / 100
      self.arrow:SetVertexColor(0.3 + perc, 1 - perc, 0)

   else
      self.arrow:SetVertexColor(1, 1, 0)
   end
end

function PlayerInfo.GpsArrow:show(player)
   self.frame:Show()
   self.targetPlayer = player
end

function PlayerInfo.GpsArrow:ShowRunTo(player)
   return self:show(player)
end

function PlayerInfo.GpsArrow:LoadPosition(point, x, y)
   self.frame:SetPoint(point, x, y);
end
