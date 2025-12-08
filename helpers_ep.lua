-- helpers_ep.lua
-- EP (EffortPoints) Helper Functions
-- Conversion rule: EP = MainStanding (Option B)
-- Officer notes remain in {EP:GP} format and are NOT modified by these helpers

local L = AceLibrary("AceLocale-2.2"):new("retroll")

-- ParseEPFromOfficerNote(officernote)
-- Extracts EP from officer note strings with pattern {EP:GP} or {EP} or free numbers
-- @param officernote - The officer note string to parse
-- @return EP value as number, or nil if not found
function RetRoll:ParseEPFromOfficerNote(officernote)
  if not officernote or officernote == "" then
    return nil
  end
  
  -- Pattern 1: {EP:GP} format (standard format)
  local _,_,ep = string.find(officernote,".*{(%d+):%-?%d+}.*")
  if ep then
    return tonumber(ep)
  end
  
  -- Pattern 2: {EP} format (legacy or simplified)
  local _,_,ep = string.find(officernote,".*{(%d+)}.*")
  if ep then
    return tonumber(ep)
  end
  
  -- Pattern 3: Free number (fallback)
  local _,_,ep = string.find(officernote,"(%d+)")
  if ep then
    return tonumber(ep)
  end
  
  return nil
end

-- GetEPForMember(memberName)
-- Retrieves EP for a member following priority:
-- 1. savedVariables members[name].EP
-- 2. officer note (via ParseEPFromOfficerNote)
-- 3. legacy MainStanding from savedVariables
-- 4. 0 (default)
-- @param memberName - The name of the guild member
-- @return EP value as number
function RetRoll:GetEPForMember(memberName)
  if not memberName then
    return 0
  end
  
  -- Priority 1: Check saved variables for EP field
  if self.db and self.db.profile and self.db.profile.members and self.db.profile.members[memberName] then
    local memberData = self.db.profile.members[memberName]
    if memberData.EP then
      return tonumber(memberData.EP) or 0
    end
  end
  
  -- Priority 2: Parse from officer note
  for i = 1, GetNumGuildMembers(1) do
    local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
    if name == memberName then
      local ep = self:ParseEPFromOfficerNote(officernote)
      if ep then
        return ep
      end
      break
    end
  end
  
  -- Priority 3: Check legacy MainStanding in saved variables
  if self.db and self.db.profile and self.db.profile.members and self.db.profile.members[memberName] then
    local memberData = self.db.profile.members[memberName]
    if memberData.MainStanding then
      return tonumber(memberData.MainStanding) or 0
    end
  end
  
  -- Priority 4: Default to 0
  return 0
end

-- SetEPForMember(memberName, ep)
-- Writes EP to savedVariables for the member
-- Does NOT modify officer notes
-- @param memberName - The name of the guild member
-- @param ep - The EP value to set
function RetRoll:SetEPForMember(memberName, ep)
  if not memberName or not ep then
    return
  end
  
  -- Initialize saved variables structure if needed
  if not self.db then
    self.db = {}
  end
  if not self.db.profile then
    self.db.profile = {}
  end
  if not self.db.profile.members then
    self.db.profile.members = {}
  end
  if not self.db.profile.members[memberName] then
    self.db.profile.members[memberName] = {}
  end
  
  -- Set EP value
  self.db.profile.members[memberName].EP = tonumber(ep) or 0
end

-- GetSavedMemberData(memberName)
-- Returns the saved data table for a member for inspection
-- @param memberName - The name of the guild member
-- @return Member data table or empty table
function RetRoll:GetSavedMemberData(memberName)
  if not memberName then
    return {}
  end
  
  if self.db and self.db.profile and self.db.profile.members and self.db.profile.members[memberName] then
    return self.db.profile.members[memberName]
  end
  
  return {}
end

-- GLOBALS: RetRoll
