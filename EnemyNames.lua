local frame = CreateFrame("FRAME");   -- Need a frame to respond to events
frame:RegisterEvent("ADDON_LOADED");  -- Fired when saved variables are loaded
frame:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out

log("running EnemyNames.lua");

self.db = EnemyNameDB or {};

table.insert(self.db, "Hello");
table.insert(self.db, "World");

log("EnemyNames:new() is called");
log(self.db);


function frame:OnEvent(event, arg1)
   if event == "ADDON_LOADED" and arg1 == "EnemyNames" then
      -- Our saved variables are ready at this point. If there are none, both variables will set to nil.
      if EnemyNameDB == nil then
         EnemyNameDB = {}; -- This is the first time this addon is loaded; initialize it

      else
         log("EnemyNameDB: ");
         log(EnemyNameDB);
      end

   elseif event == "PLAYER_LOGOUT" then
      -- todo
   end
end

frame:SetScript("OnEvent", frame.OnEvent);

function EnemyNames:new()
   self.db = EnemyNameDB;
   table.insert(self.db, "Hello");
   table.insert(self.db, "World");

   log("EnemyNames:new() is called");
   log(self.db);
end

function log(obj)
   DEFAULT_CHAT_FRAME:AddMessage(tostringall(obj));
end
