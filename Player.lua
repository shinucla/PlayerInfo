local PlayerInfo = select( 2, ... );
local Player = {};

PlayerInfo.Player = Player;
PlayerInfo.Player.__index = PlayerInfo.Player;    -- Set the __index parameter to reference Player

--------------------------------------------------------------------------------
-- lua class
--------------------------------------------------------------------------------
function PlayerInfo.Player:new(name, talent, hk)
   local self = {};                       -- Create a blank table
   setmetatable(self, PlayerInfo.Player); -- Set the metatable so we used Player's __index imbue the class

   self.name = name;
   self.talent = talent;
   self.hk = hk;
   return self;
end

function PlayerInfo.Player:print(str)
   print(str..self.name.." >> "..self.talent);
end

function PlayerInfo.Player:getColor()
   if "Restoration" == self.talent or "Holy" == self.talent or "Discipline" == self.talent then
      return 0, 1, 0;

   elseif "Protection" == self.talent or "Frost" == self.talent then
      return 0.2, 0.8, 1;

   else
      return 1, 0.4, 0.6;
   end
end
