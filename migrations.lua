local L = AceLibrary("AceLocale-2.2"):new("retroll")
function RetRoll:v2tov3()
  local count = 0
  for i = 1, GetNumGuildMembers(1) do
    local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
    local epv2 = RetRoll:get_ep_v2(name,note)
    local gpv2 = RetRoll:get_gp_v2(name,officernote)
    local epv3 = RetRoll:get_ep_v3(name,officernote)
    local gpv3 = RetRoll:get_gp_v3(name,officernote)
    if (epv3 and gpv3) then
      -- do nothing, we've migrated already
    elseif (epv2 and gpv2) and (epv2 > 0 and gpv2 >= RetRoll.VARS.baseAE) then
      count = count + 1
      -- self:defaultPrint(string.format("MainStandingv2:%s,gpv2:%s,i:%s,n:%s,o:%s",epv2,gpv2,i,name,officernote))
      RetRoll:update_epgp_v3(epv2,gpv2,i,name,officernote)
    end
  end
  self:defaultPrint(string.format(L["Updated %d members to v3 storage."],count))
  RetRoll_dbver = 3
end

-- Migrate_Main_to_EP()
-- Migrates MainStanding to EP field in saved variables
-- Conversion rule: EP = MainStanding (Option B)
-- Does NOT modify officer notes
-- Usage: Call manually via RetRoll:Migrate_Main_to_EP()
-- @return Number of members migrated
function RetRoll:Migrate_Main_to_EP()
  local count = 0
  
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
  
  -- Create backup storage
  if not self.db.profile._migration_backup_main_to_ep then
    self.db.profile._migration_backup_main_to_ep = {}
  end
  
  -- Scan all guild members
  for i = 1, GetNumGuildMembers(1) do
    local name, _, _, _, class, _, note, officernote, _, _ = GetGuildRosterInfo(i)
    
    if name then
      -- Initialize member data if needed
      if not self.db.profile.members[name] then
        self.db.profile.members[name] = {}
      end
      
      local memberData = self.db.profile.members[name]
      
      -- Only migrate if EP field doesn't exist yet
      if not memberData.EP then
        local mainStanding = memberData.MainStanding or 0
        
        -- Only migrate if MainStanding is not 0
        if mainStanding ~= 0 then
          -- Create backup
          self.db.profile._migration_backup_main_to_ep[name] = {
            MainStanding = mainStanding,
            AuxStanding = memberData.AuxStanding
          }
          
          -- Set EP = MainStanding
          memberData.EP = mainStanding
          memberData._migrated_from_main = true
          count = count + 1
        end
      end
    end
  end
  
  self:defaultPrint(string.format("Migrated %d members from MainStanding to EP.", count))
  return count
end

-- Rollback_Migrate_Main_to_EP()
-- Rolls back the migration from MainStanding to EP
-- Restores MainStanding and AuxStanding from backup
-- Removes EP field where applicable
-- Usage: Call manually via RetRoll:Rollback_Migrate_Main_to_EP()
-- @return Number of members rolled back
function RetRoll:Rollback_Migrate_Main_to_EP()
  local count = 0
  
  if not self.db or not self.db.profile or not self.db.profile._migration_backup_main_to_ep then
    self:defaultPrint("No migration backup found. Nothing to rollback.")
    return 0
  end
  
  local backup = self.db.profile._migration_backup_main_to_ep
  
  for name, backupData in pairs(backup) do
    if self.db.profile.members[name] then
      local memberData = self.db.profile.members[name]
      
      -- Restore MainStanding and AuxStanding from backup
      if backupData.MainStanding then
        memberData.MainStanding = backupData.MainStanding
      end
      if backupData.AuxStanding then
        memberData.AuxStanding = backupData.AuxStanding
      end
      
      -- Remove EP and migration marker
      memberData.EP = nil
      memberData._migrated_from_main = nil
      
      count = count + 1
    end
  end
  
  -- Clear the backup
  self.db.profile._migration_backup_main_to_ep = {}
  
  self:defaultPrint(string.format("Rolled back %d members from EP to MainStanding.", count))
  return count
end

-- GLOBALS: RetRoll_saychannel,RetRoll_groupbyclass,RetRoll_groupbyarmor,RetRoll_groupbyrole,RetRoll_raidonly,RetRoll_decay,RetRoll_minPE,RetRoll_reservechannel,RetRoll_main,RetRoll_progress,RetRoll_discount,RetRoll_log,RetRoll_dbver,RetRoll_looted
-- GLOBALS: RetRoll,RetRoll_prices,RetRoll_standings,RetRoll_bids,RetRoll_loot,RetRoll_reserves,RetRollAlts,RetRoll_logs
