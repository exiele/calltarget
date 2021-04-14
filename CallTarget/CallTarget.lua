---------------------------------------------------------------------------
--declaring addon stuff----------------------------------------------------
callTarget = LibStub("AceAddon-3.0"):NewAddon("callTarget", "AceComm-3.0", "LibNameplateRegistry-1.0");
---------------------------------------------------------------------------
--globals
target = nil
lasttarget = nil
lastNameplate = nil
lastNameplate2 = nil
markernumber = nil
lastmarkernumber = nil


--slash commands
SLASH_CT1 = "/calltarget"
SlashCmdList["CT"] = function(msg)
	if msg == '2' then
	setTarget("2")
  else
	setTarget("1")
  end
	
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

--call target 
function setTarget(markernumber)
	if UnitExists("target") then
		lasttarget = target
		target = UnitGUID("target")
		if target == lasttarget then
			removemarker(markernumber)
		else
			target = target .. markernumber
			if IsInInstance() then
				callTarget:SendCommMessage("14ae3c00985a1a89", target, "INSTANCE_CHAT") --broadcast the selected target
			else
				callTarget:SendCommMessage("14ae3c00985a1a89", target, "RAID") --broadcast the selected target
			end
		end
	elseif lastNameplate then 
		removemarker(markernumber)
	end
end
-- remove marker
function removemarker(markernumber)
	if IsInInstance() then
		callTarget:SendCommMessage("14ae3c00985a1a89", "0" .. markernumber, "INSTANCE_CHAT") --broadcast clear
	else
		callTarget:SendCommMessage("14ae3c00985a1a89", "0" .. markernumber, "RAID") --broadcast clear
	end
end
--put the marker on target's nameplate
function callTarget:LNR_ON_NEW_PLATE(eventname, plateFrame, plateData)
	
	if plateData then
		if target == plateData.GUID then
		
			if not plateFrame.myIndicator then
				plateFrame.myIndicator = plateFrame:CreateTexture(nil, "OVERLAY")
				plateFrame.myIndicator:SetSize(60,60)
				plateFrame.myIndicator:SetPoint("TOP", 0, 40)
				
			end
			if lastmarkernumber ~= markernumber then
				if markernumber == "1" then
					plateFrame.myIndicator:SetTexture("Interface\\AddOns\\CallTarget\\marker.tga")
				else
					plateFrame.myIndicator:SetTexture("Interface\\AddOns\\CallTarget\\marker2.tga")
				end
				plateFrame.myIndicator:Show()
			else
			plateFrame.myIndicator:Show()
			end
			if markernumber == "1" then
				if lastNameplate and lastNameplate ~=plateFrame then 
					lastNameplate.myIndicator:Hide() 
				end
				lastNameplate = plateFrame
			else
				if lastNameplate2 and lastNameplate2 ~=plateFrame then 
					lastNameplate2.myIndicator:Hide() 
				end
				lastNameplate2 = plateFrame
			end			
		end
	elseif markernumber == "2" then
		lastNameplate2.myIndicator:Hide()
	else
		lastNameplate.myIndicator:Hide()
	end
end

function callTarget:LNR_ON_RECYCLE_PLATE(eventname, plateFrame, plateData)
    if plateFrame.myIndicator then 
        plateFrame.myIndicator:Hide()
    end
end

-- process the broadcasted message
function callTarget:OnCommReceived(prefix, message, distribution, sender)
	target = message:sub(0,string.len(message)-1)
    markernumber = string.sub(message, -1)
	plateFrame, plateData = callTarget:GetPlateByGUID(target)
	callTarget:LNR_ON_NEW_PLATE( _, plateFrame, plateData)
end
