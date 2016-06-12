-- can't scale text with animations, use raid warning scaling
local abilityNameTimings = {
	["RAID_NOTICE_MIN_HEIGHT"] = 22.0,
	["RAID_NOTICE_MAX_HEIGHT"] = 32.0,
	["RAID_NOTICE_SCALE_UP_TIME"] = 0.1,
	["RAID_NOTICE_SCALE_DOWN_TIME"] = 0.2,
}
local timeLeftTimings = {
	["RAID_NOTICE_MIN_HEIGHT"] = 20.0,
	["RAID_NOTICE_MAX_HEIGHT"] = 28.0,
	["RAID_NOTICE_SCALE_UP_TIME"] = 0.1,
	["RAID_NOTICE_SCALE_DOWN_TIME"] = 0.2,
}

local TEXT_OVERRIDE = {
	[33786] = LOSS_OF_CONTROL_DISPLAY_CYCLONE,
	[113506] = LOSS_OF_CONTROL_DISPLAY_CYCLONE,
}

local LOSS_OF_CONTROL = "Loss of Control Alerts";
local LOSS_OF_CONTROL_DISPLAY_BANISH = "Banished";
local LOSS_OF_CONTROL_DISPLAY_CHARM = "Charmed";
local LOSS_OF_CONTROL_DISPLAY_CONFUSE = "Confused";
local LOSS_OF_CONTROL_DISPLAY_CYCLONE = "Cycloned";
local LOSS_OF_CONTROL_DISPLAY_DAZE = "Dazed";
local LOSS_OF_CONTROL_DISPLAY_DISARM = "Disarmed";
local LOSS_OF_CONTROL_DISPLAY_DISORIENT = "Disoriented";
local LOSS_OF_CONTROL_DISPLAY_DISTRACT = "Distracted";
local LOSS_OF_CONTROL_DISPLAY_FEAR = "Feared";
local LOSS_OF_CONTROL_DISPLAY_FREEZE = "Frozen";
local LOSS_OF_CONTROL_DISPLAY_HORROR = "Horrified";
local LOSS_OF_CONTROL_DISPLAY_INCAPACITATE = "Incapacitated";
local LOSS_OF_CONTROL_DISPLAY_INTERRUPT = "Interrupted";
local LOSS_OF_CONTROL_DISPLAY_INTERRUPT_SCHOOL = "%s Locked";
local LOSS_OF_CONTROL_DISPLAY_INVULNERABILITY = "Invulnerable";
local LOSS_OF_CONTROL_DISPLAY_MAGICAL_IMMUNITY = "Pacified";
local LOSS_OF_CONTROL_DISPLAY_PACIFY = "Pacified";
local LOSS_OF_CONTROL_DISPLAY_PACIFYSILENCE = "Disabled";
local LOSS_OF_CONTROL_DISPLAY_POLYMORPH = "Polymorphed";
local LOSS_OF_CONTROL_DISPLAY_POSSESS = "Possessed";
local LOSS_OF_CONTROL_DISPLAY_ROOT = "Rooted";
local LOSS_OF_CONTROL_DISPLAY_SAP = "Sapped";
local LOSS_OF_CONTROL_DISPLAY_SCHOOL_INTERRUPT = "Interrupted";
local LOSS_OF_CONTROL_DISPLAY_SHACKLE_UNDEAD = "Shackled";
local LOSS_OF_CONTROL_DISPLAY_SILENCE = "Silenced";
local LOSS_OF_CONTROL_DISPLAY_SLEEP = "Asleep";
local LOSS_OF_CONTROL_DISPLAY_SNARE = "Snared";
local LOSS_OF_CONTROL_DISPLAY_STUN = "Stunned";
local LOSS_OF_CONTROL_DISPLAY_STUN_MECHANIC = "Stunned";
local LOSS_OF_CONTROL_DISPLAY_TURN_UNDEAD = "Feared";

local TIME_LEFT_FRAME_WIDTH = 200;
local LOSS_OF_CONTROL_TIME_OFFSET = 6;

local DISPLAY_TYPE_FULL = 2;
local DISPLAY_TYPE_ALERT = 1;
local DISPLAY_TYPE_NONE = 0;

local ACTIVE_INDEX = 1;


local RaidNotice_UpdateSlot

local DISPLAY_TYPE_ALERT = "DISPLAY_TYPE_ALERT"


local CC_priority = {
["Renew"] = 3, --debug 
["Prayer of Mending"] = 2,
}

local feared = "Feared"
local stunned = "Stunned"
local silenced = "Silenced"
local disarmed = "Disarmed"
local rooted = "Rooted"
local incapacitated = "Incapacitated"

local priority_by_type = {
Blinded = 5,
Cycloned = 5,

Feared = 4,
Polymorphed = 4,
Banished = 4,

Horrified = 3,

Stunned = 3,
Silenced = 3,
Incapacitated = 3,


Disarmed = 2,
Rooted = 1,

}

local priority_by_spell = {}

local CC_type = {
-- Priest 
["Shackle Undead"] = "Shackled",
["Psychic Scream"] = feared,
["Mind Control"] = "Charmed",
["Psychic Horror"] = "Horrified",
-- Mage 
["Polymorph"] = "Polymorphed",
["Deep Freeze"] = stunned,
["Counterspell"] = silenced,
["Dragon's Breath"] = incapacitated,
["Frost Nova"] = rooted,

-- Warlock 
["Shadowfury"] = stunned,
["Death Coil"] = "Horrified",
["Fear"] = feared,
["Howl of Terror"] = "Disoriented",
["Banish"] = "Banished",

-- DK 
["Gnaw"] = stunned,
["Hungering Cold"] = incapacitated,
["Strangulate"] = silenced,
-- Warrior
["Charge Stun"] = stunned,
["Intercept Stun"] = stunned,
["Intimidating Shout"] = feared,
["Shockwave"] = stunned,
["Concussion Blow"] = stunned,

-- Rogue 
["Disarm"] = disarmed,
["Dismantle"] = disarmed,
["Sap"] = "Sapped",
["Gouge"] = "Gouged",

["Kidney Shot"] = stunned,
["Cheap Shot"] = stunned,
["Blind"] = "Blinded",


-- Druid 
["Entangling Roots"] = rooted,
["Freeze"] = rooted,
["Cyclone"] = "Cycloned",
["Bash"] = stunned,
["Maim"] = stunned,

-- Paladin 
["Turn Evil"] = feared,
["Hammer of Justice"] = stunned,

-- Hunter 
["Freezing Trap"] = incapacitated,
["Scatter Shot"] = incapacitated,
["Entrapment"] = rooted,

}

local temp_auras = {}
local function GetUnitCC_Effect(unit)
for k in pairs(temp_auras) do 
temp_auras[k] = nil 
end 

local i = 1 
local highest_priority
local highest_priority_name 
local expiration 
while true do
local name, rank, texture, count, debuffType, duration, expirationTime, sourceUnit  = UnitAura(unit, i, "HARMFUL")

if name then 
local _cctype = CC_type[name] 
if _cctype then 
local priority = priority_by_type[_cctype] or priority_by_spell[name] or 0 

	if name and ( not highest_priority or priority > highest_priority or (priority==highest_priority and expiration<=expirationTime ) ) then
	highest_priority = priority
	highest_priority_name = name 
	expiration = expirationTime
	temp_auras[name] = CC_priority[name]
	end 
end 
else 
	break 
end 
i = i +1 
end 

if highest_priority_name then 
local name, rank, texture, count, debuffType, duration, expirationTime, sourceUnit  = UnitAura(unit, highest_priority_name, nil, "HARMFUL")
 return "", name, CC_type[name], texture, expirationTime-duration, expirationTime-GetTime(), duration, "", 3, ""
end 
end 

function LossOfControlFrame_OnLoad(self)
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("VARIABLES_LOADED");
	-- figure out some string widths - our base width is for under 10 seconds which should be almost all loss of control durations
	self.TimeLeft.baseNumberWidth = self.TimeLeft.NumberText:GetStringWidth() + LOSS_OF_CONTROL_TIME_OFFSET;
	self.TimeLeft.secondsWidth = self.TimeLeft.SecondsText:GetStringWidth();
end

function LossOfControlFrame_OnEvent(self, event, ...)
	if ( event == "LOSS_OF_CONTROL_UPDATE" ) then
		LossOfControlFrame_UpdateDisplay(self, false);
	elseif ( event == "LOSS_OF_CONTROL_ADDED" ) then
		--local eventIndex = ...;
		local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = C_LossOfControl.GetEventInfo(eventIndex);
		if ( displayType == "DISPLAY_TYPE_ALERT" ) then
			-- only display an alert type if there's nothing up or it has higher priority. If same priority, it needs to have longer time remaining
			if ( not self:IsShown() or priority > self.priority or ( priority == self.priority and timeRemaining and ( not self.TimeLeft.timeRemaining or timeRemaining > self.TimeLeft.timeRemaining ) ) ) then
				LossOfControlFrame_SetUpDisplay(self, true, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType);
			end
			return;
		end
		if ( eventIndex == ACTIVE_INDEX ) then
			self.fadeTime = nil;
			LossOfControlFrame_SetUpDisplay(self, true);
		end
	elseif ( event == "UNIT_AURA" ) then 
		local unit = ...
		
		if unit =="player" then 
		local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = GetUnitCC_Effect(unit)
		if locType then 
		self.startTime = startTime 
		--if ( displayType == "DISPLAY_TYPE_ALERT" ) then
			-- only display an alert type if there's nothing up or it has higher priority. If same priority, it needs to have longer time remaining
			if ( not self:IsShown() or priority > self.priority or ( priority == self.priority and timeRemaining and ( not self.TimeLeft.timeRemaining or timeRemaining > self.TimeLeft.timeRemaining ) ) ) then
				LossOfControlFrame_SetUpDisplay(self, true, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType);
			
			end
			return;
			else 
			self:Hide()
		end
		
		end 
		
	elseif ( event == "CVAR_UPDATE" ) then
		local cvar, value = ...;
		if ( cvar == "LOSS_OF_CONTROL" ) then
			if ( value == "1" ) then
				self:RegisterEvent("LOSS_OF_CONTROL_UPDATE");
				self:RegisterEvent("LOSS_OF_CONTROL_ADDED");
			else
				self:UnregisterEvent("LOSS_OF_CONTROL_UPDATE");
				self:UnregisterEvent("LOSS_OF_CONTROL_ADDED");
				self:Hide();
			end
		end
	elseif ( event == "VARIABLES_LOADED" ) then
		if ( GetCVarBool("lossOfControl" ) ) then
			self:RegisterEvent("LOSS_OF_CONTROL_UPDATE");
			self:RegisterEvent("LOSS_OF_CONTROL_ADDED");
		end
	end
end


function LossOfControlFrame_OnUpdate(self, elapsed)

	
	RaidNotice_UpdateSlot(self.AbilityName, abilityNameTimings, elapsed);
	RaidNotice_UpdateSlot(self.TimeLeft.NumberText, timeLeftTimings, elapsed);
	RaidNotice_UpdateSlot(self.TimeLeft.SecondsText, timeLeftTimings, elapsed);
	
	-- handle alert type
	if(self.fadeTime) then
		self.fadeTime = self.fadeTime - elapsed;
		self:SetAlpha(max(self.fadeTime*2, 0.0));
		if(self.fadeTime < 0) then
			self:Hide();
		else
			-- no need to do any other work
			return;
		end
	else
		self:SetAlpha(1.0);
	end
	LossOfControlFrame_UpdateDisplay(self);	
end

function LossOfControlFrame_OnHide(self)
	self.fadeTime = nil;
	self.priority = nil;
end

function LossOfControlFrame_SetUpDisplay(self, animate, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType)
	if ( not locType ) then
		locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = GetUnitCC_Effect("player")--C_LossOfControl.GetEventInfo(ACTIVE_INDEX);
	end
	if ( text and displayType ~= DISPLAY_TYPE_NONE ) then
		-- ability name
		text = TEXT_OVERRIDE[spellID] or text;
		if ( locType == "SCHOOL_INTERRUPT" ) then
			-- Replace text with school-specific lockout text
			if(lockoutSchool and lockoutSchool ~= 0) then
				text = string.format(LOSS_OF_CONTROL_DISPLAY_INTERRUPT_SCHOOL, GetSchoolString(lockoutSchool));
			end
		end
		self.AbilityName:SetText(text);
		-- icon
		self.Icon:SetTexture(iconTexture);
		
		-- time
		local timeLeftFrame = self.TimeLeft;
		if ( displayType == DISPLAY_TYPE_ALERT ) then
			timeRemaining = duration;
			--CooldownFrame_Clear(self.Cooldown);
		elseif ( not startTime ) then
			-- CooldownFrame_Clear(self.Cooldown);
		else
			--CooldownFrame_Set(self.Cooldown, startTime, duration, true);
			self.Cooldown:SetCooldown(startTime, duration, true)
		end
		if timeRemaining>= 0 then 
		LossOfControlTimeLeftFrame_SetTime(timeLeftFrame, timeRemaining, duration);
		else 
		self:Hide() 
		return 
		end 
		-- align stuff
		local abilityWidth = self.AbilityName:GetWidth();
		local longestTextWidth = max(abilityWidth, (timeLeftFrame.numberWidth + timeLeftFrame.secondsWidth));
		local xOffset = (abilityWidth - longestTextWidth) / 2 + 27;
		self.AbilityName:SetPoint("CENTER", xOffset, 11);
		self.Icon:SetPoint("CENTER", -((6 + longestTextWidth) / 2), 0);
		-- left-align the TimeLeft frame with the ability name using a center anchor (will need center for "animating" via frame scaling - NYI)
		xOffset = xOffset + (TIME_LEFT_FRAME_WIDTH - abilityWidth) / 2;
		timeLeftFrame:SetPoint("CENTER", xOffset, -12);
		-- show
		if ( animate ) then
			if ( displayType == DISPLAY_TYPE_ALERT ) then
				self.fadeTime = 1.5;
			end
			self.Anim:Stop();
			self.AbilityName.scrollTime = 0;
			self.TimeLeft.NumberText.scrollTime = 0;
			self.TimeLeft.SecondsText.scrollTime = 0;
			self.Cooldown:Hide();
			self.Anim:Play();
			--PlaySoundKitID(34468);
		end
		self.priority = priority;
		self.spellID = spellID;
		self.startTime = startTime;
		self:Show();
	end
end

function LossOfControlFrame_UpdateDisplay(self)
	-- if displaying an alert, wait for it to go away on its own
	if ( self.fadeTime ) then
		return;
	end
	
	local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = GetUnitCC_Effect("player")-- C_LossOfControl.GetEventInfo(ACTIVE_INDEX);
	LossOfControlTimeLeftFrame_SetTime(self.TimeLeft, timeRemaining, duration);
	
	do return end 

	if ( text and displayType == DISPLAY_TYPE_FULL ) then
		if ( spellID ~= self.spellID or startTime ~= self.startTime ) then
			LossOfControlFrame_SetUpDisplay(self, false, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType);
		end
		if ( not self.Anim:IsPlaying() and startTime ) then
			--CooldownFrame_Set(self.Cooldown, startTime, duration, true, true);
			self.Cooldown:SetCooldown(startTime, duration, true)
		end
		--LossOfControlTimeLeftFrame_SetTime(self.TimeLeft, timeRemaining);
	else
		self:Hide();
	end
end

function LossOfControlTimeLeftFrame_SetTime(self, timeRemaining, duration)
	
	if( timeRemaining ) then
		if ( timeRemaining >= 10 ) then
			self.NumberText:SetFormattedText("%d", timeRemaining);
		elseif (timeRemaining < 9.95) then -- From 9.95 to 9.99 it will print 10.0 instead of 9.9
			self.NumberText:SetFormattedText("%.1F", timeRemaining);
		end
		self:Show();
		self.timeRemaining = timeRemaining;
		self.numberWidth = self.NumberText:GetStringWidth() + LOSS_OF_CONTROL_TIME_OFFSET;
		
		self.SecondsText:SetText("/"..tostring(duration))
	else
		self:Hide();
		self.numberWidth = 0;
	end
end

function RaidNotice_UpdateSlot( slotFrame, timings, elapsedTime )
	if ( slotFrame.scrollTime ) then
		slotFrame.scrollTime = slotFrame.scrollTime + elapsedTime;
		if ( slotFrame.scrollTime <= timings["RAID_NOTICE_SCALE_UP_TIME"] ) then
			slotFrame:SetTextHeight(floor(timings["RAID_NOTICE_MIN_HEIGHT"]+((timings["RAID_NOTICE_MAX_HEIGHT"]-timings["RAID_NOTICE_MIN_HEIGHT"])*slotFrame.scrollTime/timings["RAID_NOTICE_SCALE_UP_TIME"])));
		elseif ( slotFrame.scrollTime <= timings["RAID_NOTICE_SCALE_DOWN_TIME"] ) then
			slotFrame:SetTextHeight(floor(timings["RAID_NOTICE_MAX_HEIGHT"] - ((timings["RAID_NOTICE_MAX_HEIGHT"]-timings["RAID_NOTICE_MIN_HEIGHT"])*(slotFrame.scrollTime - timings["RAID_NOTICE_SCALE_UP_TIME"])/(timings["RAID_NOTICE_SCALE_DOWN_TIME"] - timings["RAID_NOTICE_SCALE_UP_TIME"]))));
		else
			slotFrame:SetTextHeight(timings["RAID_NOTICE_MIN_HEIGHT"]);
			slotFrame.scrollTime = nil;
		end
	end	
--	FadingFrame_OnUpdate(slotFrame);
end


