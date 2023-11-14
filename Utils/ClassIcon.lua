local AceAddon = LibStub("AceAddon-3.0");
local NAME_PLATE_LIB = LibStub("LibNameplate-1.0");

--------------------------------------------------------------------------------

local addon = AceAddon:GetAddon("PlayerInfo");
local util = {}

addon.Utils.ClassIcon = util;

util.nameplateIconFrameNameCounter = 1

function util:AddVariables(db)
   db.IconSettings = db.IconSettings or self:GetDefaultNameplateIconSettings();
end

function util:GetDefaultNameplateIconSettings()
   return
      {
         Size = 32,
         Alpha = 1,
         EnemiesOnly = false,
         DisplayClassIconBorder = true,
         BorderFollowNameplateColor = true,
         OffsetX = 7,
         OffsetY = -9,
         ShowQuestionMarks = false
      }
end

function util:GetNameplateFrame(nameplate)
   return nameplate.nameplateIcon;
end

function util:GetOrCreateNameplateIconFrame(nameplate)
   if nameplate.nameplateIcon == nil then
      print("===== Creating icon frame for the nameplate: "..NAME_PLATE_LIB:GetName(nameplate));
      local nameplateIcon = CreateFrame("Frame", 'PlayerInfoIconFrame' .. util.nameplateIconFrameNameCounter, nameplate);
      util.nameplateIconFrameNameCounter = util.nameplateIconFrameNameCounter + 1;

      nameplateIcon.Clear = function(this)
         this:Hide();
         this:SetMetadata({}, nil)
         this:SetCustomAppearance(nil)
         this.classBorderTexture:Hide();
      end

      nameplateIcon.SetCustomAppearance = function(this, appearenceFunc)
         this.customAppearance = appearenceFunc;
      end

      nameplateIcon.SetMetadata = function(this, metadata, targetName)
         this.class = metadata.class;
         this.isPlayer = metadata.isPlayer;
         this.isHostile = metadata.isHostile;
         this.isPet = metadata.isPet;
         this.targetName = targetName;
      end

      nameplateIcon.PrintTable = function(tbl)
         local result = "{"
         for key, value in pairs(tbl) do
            result = result .. key .. "=" .. tostring(value) .. ", "
         end
         result = result:sub(1, -3) .. "}"  -- Remove the trailing comma and space
         return result
      end

      -- this is where the icon shows
      nameplateIcon.UpdateAppearence = function(this, customSettings)
	 -- this.targetName=Boneripper
	 -- this.class=Ghoul
	 -- this.isPet=true
	 -- this.UpdateAppearence=function
	 -- this.....

	 -- ONLY SHOWING FOR PLAYERS
	 --if this.isPlayer ~= tue then
	 --   return
	 --end
	 
         -- print("nameplateIcon.UpdateAppearence : this = "..this.targetName);

         local settings = customSettings;

         if settings.EnemiesOnly and this.isHostile == false then
            return
         end

         if this.isPlayer ~= true and settings.playersOnly ~= false then
            return
         elseif this.class == nil then
            if settings.ShowQuestionMarks then
               SetPortraitToTexture(this.classTexture,"Interface\\Icons\\Inv_misc_questionmark")
               this.classTexture:SetTexCoord(0.075, 0.925, 0.075, 0.925);
               this:Show();

	    elseif settings.ShowPlusIcon then
	       SetPortraitToTexture(this.classTexture,"Interface\\Icons\\Inv_shield_48")
	       --SetPortraitToTexture(this.classTexture,"Interface\\AddOns\\PlayerInfo\\plus_PNG26.png")
               this.classTexture:SetTexCoord(0.075, 0.925, 0.075, 0.925);
               this:Show();	       

	    else
               this.classTexture:SetTexture(nil)

	    end
         elseif this.isPlayer then
            this.classTexture:SetTexture(addon.path .. "\\images\\UI-CHARACTERCREATE-CLASSES_ROUND");
            if CLASS_ICON_TCOORDS[this.class] == nil then
               error("Unexpected class:", this.class)
            end
            this.classTexture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[this.class]));
            this:Show();
         end

         if this.class ~= nil and settings.DisplayClassIconBorder then
            this.classBorderTexture:Show();
         else
            this.classBorderTexture:Hide();
         end

         this.FollowNameplateColor = settings.FollowNameplateColor;
         this:SetAlpha(settings.Alpha or 1);
         this:SetWidth(settings.Size or 32);
         this:SetHeight(settings.Size or 32);
         -- KEVIN
         this:SetPoint("RIGHT", nameplate, "RIGHT", settings.OffsetX, settings.OffsetY);
	 this:Show();

         if this.customAppearance ~= nil then
            this.customAppearance(this)
         end
      end

      local texture = nameplateIcon:CreateTexture(nil, "ARTWORK");
      texture:SetAllPoints();
      nameplateIcon.classTexture = texture;

      local textureBorder = nameplateIcon:CreateTexture(nil, "BORDER");
      textureBorder:SetTexture(addon.path .. "\\images\\RoundBorder");
      textureBorder:SetAllPoints()
      textureBorder:Hide()
      nameplateIcon.classBorderTexture = textureBorder;
      nameplate.nameplateIcon = nameplateIcon;
   end

   return nameplate.nameplateIcon;
end

function util:AddBlizzardOptions(options, dbConnection, iterator)
   if iterator == nil then
      iterator = Utils.Iterator:New();
   end

   options.args["ClassIconDescriptionSpace"] =
      {
         type = "description",
         name = " ",
         fontSize = "large",
         order = iterator()
      }

   options.args["ClassIconDescription"] =
      {
         type = "description",
         width = "full",
         name = "Class icon Settings:",
         fontSize = "large",
         order = iterator()
      }

   options.args["Size"] =
      {
         type = "range",
         name = "Size",
         desc = "",
         min = 0,
         max = 256,
         softMin = 8,
         softMax = 64,
         step = 2,
         order = iterator(),
         get = dbConnection.Get,
         set = dbConnection.Set
      }

   options.args["Alpha"] =
      {
         type = "range",
         name = "Alpha",
         desc = "",
         min = 0,
         max = 1,
         step = 0.1,
         order = iterator(),
         get = dbConnection.Get,
         set = dbConnection.Set
      }


   options.args["OffsetX"] =
      {
         type = "range",
         name = "OffsetX",
         desc = "",
         softMin = -80,
         softMax = 240,
         step = 1,
         order = iterator(),
         get = dbConnection.Get,
         set = dbConnection.Set
      }

   options.args["OffsetY"] =
      {
         type = "range",
         name = "OffsetY",
         desc = "",
         softMin = -80,
         softMax = 80,
         step = 1,
         order = iterator(),
         get = dbConnection.Get,
         set = dbConnection.Set
      }

   options.args["DisplayClassIconBorder"] =
      {
         type = "toggle",
         name = "Display border",
         desc = "",
         order = iterator(),
         get = dbConnection.Get,
         set = dbConnection.Set
      }

   options.args["BorderFollowNameplateColor"] =
      {
         type = "toggle",
         name = "Dynamic border color",
         desc = "Set border color to the color of the nameplate",
         order = iterator(),
         get = dbConnection.Get,
         set = dbConnection.Set
      }

   options.args["ShowQuestionMarks"] =
      {
         type = "toggle",
         name = "Show question marks",
         desc = "Show question marks for targets with unknown status",
         order = iterator(),
         get = dbConnection.Get,
         set = dbConnection.Set
      }

   options.args["EnemiesOnly"] =
      {
         type = "toggle",
         name = "Enemies only",
         desc = "Show icons for enemies only",
         order = iterator(),
         get = dbConnection.Get,
         set = dbConnection.Set
      }
end
