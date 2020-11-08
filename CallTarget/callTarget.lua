---------------------------------------------------------------------------
--declaring addon stuff----------------------------------------------------
callTarget = LibStub("AceAddon-3.0"):NewAddon("callTarget", "AceComm-3.0", "AceEvent-3.0", "LibNameplateRegistry-1.0");
---------------------------------------------------------------------------
--globals
target = nil
lastNameplate = nil


--slash command
SLASH_CT1 = "/calltarget"
SlashCmdList["CT"] = function(msg)
	setTarget()
end 

function callTarget:OnInitialize()
	self:RegisterComm("14ae3c00985a1a89");
end

function callTarget:OnEnable()
    -- Subscribe to callbacks
    self:LNR_RegisterCallback("LNR_ON_NEW_PLATE");
    self:LNR_RegisterCallback("LNR_ON_RECYCLE_PLATE");
end

function callTarget:OnDisable()
    -- Unsubscribe to callbacks	
    self:LNR_UnregisterAllCallbacks();
end

--set the call target 
function setTarget()
	if UnitExists("target") then
		target = UnitGUID("target")
		if IsInInstance() then
			callTarget:SendCommMessage("14ae3c00985a1a89", target, "INSTANCE_CHAT") --broadcast the selected target
		else
			callTarget:SendCommMessage("14ae3c00985a1a89", target, "RAID") --broadcast the selected target
		end
		
	end
end

--put the marker on target's nameplate
function callTarget:LNR_ON_NEW_PLATE(eventname, plateFrame, plateData)
	
	if plateData then
		if target == plateData.GUID then
		
			if not plateFrame.myIndicator then
				plateFrame.myIndicator = plateFrame:CreateTexture(nil, "OVERLAY")
				plateFrame.myIndicator:SetTexture("Interface\\AddOns\\CallTarget\\marker.tga")
				plateFrame.myIndicator:SetSize(60,60)
				plateFrame.myIndicator:SetPoint("TOP", 0, 40)
			end
			plateFrame.myIndicator:Show()
			if lastNameplate and lastNameplate ~=plateFrame then 
				lastNameplate.myIndicator:Hide() 
			end
			lastNameplate = plateFrame
		end
	end
end

function callTarget:LNR_ON_RECYCLE_PLATE(eventname, plateFrame, plateData)
    if plateFrame.myIndicator then 
        plateFrame.myIndicator:Hide()
    end
end

-- process the broadcasted message
function callTarget:OnCommReceived(prefix, message, distribution, sender)
    target = message
	plateFrame, plateData = callTarget:GetPlateByGUID(target)
	callTarget:LNR_ON_NEW_PLATE( _, plateFrame, plateData)
end
