#include "x2_inc_switches"
#include "x2_inc_restsys"
#include "inc_treasure"
#include "nwnx_admin"
#include "nwnx_weapon"
#include "nwnx_events"

#include "70_inc_switches"

void main()
{
// Set up some server options
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_ENFORCE_LEGAL_CHARACTERS, TRUE);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_ITEM_LEVEL_RESTRICTIONS, TRUE);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_AUTO_FAIL_SAVE_ON_1, TRUE);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_EXAMINE_EFFECTS, FALSE);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_USE_MAX_HITPOINTS, TRUE);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_RESTORE_SPELLS_USES, FALSE);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_HIDE_HITPOINTS_GAINED, FALSE);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_PVP_SETTING, 2);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_VALIDATE_SPELLS, TRUE);

// Set a password until everything is initialized and ready
    NWNX_Administration_SetPlayerPassword(GetRandomUUID());

// Initialize monk weapons
    NWNX_Weapon_SetWeaponIsMonkWeapon(BASE_ITEM_QUARTERSTAFF);
    NWNX_Weapon_SetWeaponIsMonkWeapon(BASE_ITEM_SHURIKEN);

// Events.
    NWNX_Events_SubscribeEvent("NWNX_ON_QUICKCHAT_BEFORE", "on_pc_voiceb");
    NWNX_Events_SubscribeEvent("NWNX_ON_CLIENT_CONNECT_AFTER", "on_pc_connect");
    NWNX_Events_SubscribeEvent("NWNX_ON_CLIENT_DISCONNECT_AFTER", "on_pc_dconnect");

    NWNX_Events_SubscribeEvent("NWNX_ON_USE_SKILL_BEFORE", "on_pc_skillb");
    NWNX_Events_SubscribeEvent("NWNX_ON_USE_SKILL_AFTER", "on_pc_skilla");

    NWNX_Events_SubscribeEvent("NWNX_ON_HEALER_KIT_BEFORE", "on_pc_healkit");

    NWNX_Events_SubscribeEvent("NWNX_ON_ENTER_STEALTH_BEFORE", "on_pc_stealth");

    NWNX_Events_SubscribeEvent("NWNX_ON_TRAP_RECOVER_BEFORE", "on_pc_trap");
    NWNX_Events_SubscribeEvent("NWNX_ON_TRAP_FLAG_BEFORE", "on_pc_trap");
    NWNX_Events_SubscribeEvent("NWNX_ON_TRAP_DISARM_BEFORE", "on_pc_trap");
    NWNX_Events_SubscribeEvent("NWNX_ON_TRAP_SET_BEFORE", "on_pc_trap");

    NWNX_Events_SubscribeEvent("NWNX_ON_OBJECT_LOCK_BEFORE", "on_pc_lock");
    NWNX_Events_SubscribeEvent("NWNX_ON_OBJECT_UNLOCK_BEFORE", "on_pc_unlock");

    NWNX_Events_SubscribeEvent("NWNX_ON_ITEM_PAY_TO_IDENTIFY_AFTER", "mer_identify");

    NWNX_Events_SubscribeEvent("NWNX_ON_INPUT_CAST_SPELL_BEFORE", "on_pc_spcastb");
    NWNX_Events_SubscribeEvent("NWNX_ON_BROADCAST_CAST_SPELL_BEFORE", "on_pc_spcastb");

// We do some things different on DEV and local (without NWNX), such as ignoring webhooks and having verbose debug messages
    if ((NWNX_Time_GetTimeStamp() == 0) || FindSubString(NWNX_Administration_GetServerName(), "DEV") > -1)
    {
        SetLocalInt(OBJECT_SELF, "dev", 1);
        SetLocalInt(OBJECT_SELF, "debug_verbose", 1);
    }

   // Multiple henchmen on the server, so let's set a high limit.
   SetMaxHenchmen(999);

   // * 1.72: Activating this switch below will allow to use only one damage shield spell at once.
   // * Affected spells: elemental shield, mestil's acid sheat, aura vs alignment, death armor
   // * and wounding whispers.
   // * When one of these spells is cast, any other such spell is dispelled.
   SetModuleSwitch (MODULE_SWITCH_DISABLE_DAMAGE_SHIELD_STACKING, TRUE);

   // * 1.72: Activating this switch below will allow to use only one weapon boost spell at once.
   // * Affected spells: magic weapon, greater magic weapon, bless weapon, flame weapon, holy sword,
   // * deafning clang, keen edge, darkfire and black staff.
   // * When one of these spells is cast on same item, the item gets stripped of all
   // * temporary itemproperties.
   SetModuleSwitch (MODULE_SWITCH_DISABLE_WEAPON_BOOST_STACKING, TRUE);

   // * 1.72: This switch controlls how much persistent AOE spells of the same type can player cast
   // * in the same area. This will stop the cheesy tactics to stack dozen of blade barries or
   // * acid fogs and lure monsters into it.
   // * Unlike weapon boosts and damage shields, this switch allows to set specific number of
   // * allowed aoes spells, so 1 = max 1, 2 = max 2 etc.
   SetModuleSwitch (MODULE_SWITCH_DISABLE_AOE_SPELLS_STACKING, 1);

   // * 1.72: Activating this switch below will enable hardcore DnD rules for evasion and improved
   // * evasion. Evasion feats will only work in light or no armor. Also a character must not
   // * be helpless ie. under effects of stun, paralysis, petrify, sleep or timestop.
   SetModuleSwitch (MODULE_SWITCH_HARDCORE_EVASION_RULES, TRUE);

   // * 1.72: Activating this switch below will disable "polymorph end" check which is
   // * performed every 6 seconds via pseudo heartbeat in order to clean all polymorph
   // * related effects such as ability bonuses, temporary hp etc. in case a module doesn't
   // * have properly merged module events with 1.72. Activating this switch will disable
   // * this check which is useful in multiplayer to make the polymorph new system more optimized.
   // * Make sure that you got OnEquip and OnUnEquip events merged properly before disabling this!
   // SetModuleSwitch (MODULE_SWITCH_POLYMORPH_DISABLE_POLYMORPH_END_CHECK, TRUE);

   // * 1.72: Activating this switch below will allow to merge every items the character wears into
   // * every polymorph shape in game even Tenser's transformation. This automatically enables
   // * the "merge arms" switch.
   // * Note: for unarmed shapes only defensive properties from weapon will merge.
   SetModuleSwitch (MODULE_SWITCH_POLYMORPH_MERGE_EVERYTHING, TRUE);

   // * 1.72: Activating this switch below will allow to merge intelligence, charisma and wisdom from
   // * all items no matter if the shape merges them or not. The reason for this is when you want to
   // * stop losing spellslots from ability increases on items while polymorphed.
   // * In case the player is a monk, he will get AC decrease matching the increase in wisdom
   // * over what shape normally allows.
   // * Note, use this switch only when module is not running NWNX. NWN(C)X_Patch handles this
   // * automatically in a better way - slots which would be normally lost will only be
   // * consumed. Also note this won't fix, unlike NWNX, losing spell slots from bonus spell slot
   // * itemproperties.
   SetModuleSwitch (MODULE_SWITCH_POLYMORPH_MERGE_CASTING_ABILITY, TRUE);

   // * 1.71: Activating this switch below will enforce the SoU empower spell feat behavior.
   // * This behavior empowers only dice values and any bonuses are added to the final result.
   // * Note: By default, empower spell feat empowers result of dice+bonus reaching much higher
   // * values, often outshining the maximized spell feat result.
   // SetModuleSwitch (MODULE_SWITCH_SOU_EMPOWER_SPELL_BEHAVIOR, TRUE);

   // * 1.71: Activating this switch below will enable to summon more than one summoned
   // * creature at the same time. Value TRUE/1 means unlimited, but it can be set to 2,3, etc.
   // SetModuleSwitch (MODULE_SWITCH_UNLIMITED_SUMMONING, TRUE);

   // * 1.71: Activating this switch below will stack multiple same bonuses and penalties
   // * to the single ability together, by default only highest applies.
   SetModuleSwitch (MODULE_SWITCH_POLYMORPH_STACK_ABILITY_BONUSES, TRUE);

   // * 1.71: Activating this switch below will enable to merge bracers/gloves when polymorphing.
   // * This will work only for shapes that merges items. Also only defensive abilities works.
   SetModuleSwitch (MODULE_SWITCH_POLYMORPH_MERGE_ARMS, TRUE);

   // * 1.71: Activating this switch below will calculate Pale master levels into
   // * caster level calculation. This will affect only arcane spells cast normally.
   // * Not all PM levels counts, under default 2DA setting the bonus to the caster
   // * level is (PM level/2)+1 - even levels do not affect spellcasting abilities.
   SetModuleSwitch (MODULE_SWITCH_PALEMASTER_ADDS_CASTER_LEVEL, TRUE);

   // * 1.71: Activating this switch below will restrict usage of the musical instruments.
   // * Possible values:
   // * 1: instruments will be restricted to the Perform skill, DC for success
   // * is then same as for UMD, 7+(3*SpellLevel)
   // * 2: instruments will be restricted to the bard song feat, just the way
   // * the Lich lyric are, each casting will decrement one use of the bard song feat
   // SetModuleSwitch (MODULE_SWITCH_RESTRICT_MUSICAL_INSTRUMENTS, 1);

   // * 1.71: Activating this switch below will shorten the duration of all disable effects
   // * (stun, paralyse, charm, daze, confusion, dominate, entangle, knockdown, grapple)
   // * to the constant of 3rounds (unless effect comes from extended spell)
   // * Possible values:
   // * 1: apply only when caster isn't PC and target is PC or his associate
   // * 2: apply regardless of who is caster but only when target is PC or his associate
   // * 3: apply regardless of who is caster and who target
   // SetModuleSwitch (MODULE_SWITCH_SHORTENED_DURATION_OF_DISABLE_EFFECTS, 1);

   // * 1.71: By default creature affected by the poison effect itself is virtually
   // * immune to other poisons until this effect wears off. This switch changes this
   // * behavior and adds greater effect to the poisons.
   SetModuleSwitch (MODULE_SWITCH_ALLOW_POISON_STACKING, TRUE);

   // * 1.71: Activating one of the switches below will enable to various weapon boost spells to
   // * affect additional weapons. Of course the spells still apply other rules such as slashing only
   // * etc. so this will not allow to cast keen on gloves.
   SetModuleSwitch (MODULE_SWITCH_ALLOW_BOOST_THROWING_WEAPONS, TRUE);
   SetModuleSwitch (MODULE_SWITCH_ALLOW_BOOST_RANGED_AND_AMMO, TRUE);
   SetModuleSwitch (MODULE_SWITCH_ALLOW_BOOST_GLOVES, TRUE);

   // * 1.70: Activating the switch below will enable the AOE heartbeat workaround solution
   // * if the default heartbeat solution doesn't work and AOEs do nothing
   // SetModuleSwitch (MODULE_SWITCH_AOE_HEARTBEAT_WORKAROUND, TRUE);

   // * 1.70: Activating the switch below will enable item sold to store tracking, once the limit
   // * of sold items, in this case 100, will be reached, oldest item sold to store will be destroyed
   // SetModuleSwitch (MODULE_SWITCH_OVERFILLED_STORES_ISSUE_FIX, 100);

   // * 1.70: Activating the switch below will disable the spell resist check inside AOEs, thus
   // * these spells will ignore spell resistance, spell mantle and even spell immunity
   // SetModuleSwitch (MODULE_SWITCH_AOE_IGNORES_SPELL_RESISTANCE, TRUE);

   // * 1.70: Activating the switch below will revert the 1.70's "Spell Immunity precedence"
   // inside ResistSpell check back to the 1.69 behavior where spell mantle "goes first".
   // SetModuleSwitch (MODULE_SWITCH_SPELL_MANTLE_169_BEHAVIOR, TRUE);

   // * 1.70: Activating the switch below will revert the 1.70's Dusty Rose ioun stone dodge AC
   // balance change back to the 1.69 deflection.
   // SetModuleSwitch (MODULE_SWITCH_DUSTYROSE_IOUNSTONE_169_AC_TYPE, TRUE);

   // * 1.70: Activating the switch below will disable the 1.70's feature that mark item as stolen
   // This was already modifed personally so don't use it.
   // SetModuleSwitch (MODULE_SWITCH_CONTINUAL_FLAME_ALLOW_EXPLOIT, TRUE);

   // * Setting the switch below will enable a seperate Use Magic Device Skillcheck for
   // * rogues when playing on Hardcore+ difficulty. This only applies to scrolls
   SetModuleSwitch (MODULE_SWITCH_ENABLE_UMD_SCROLLS, TRUE);

   // * Activating the switch below will make AOE spells hurt neutral NPCS by default
   SetModuleSwitch (MODULE_SWITCH_AOE_HURT_NEUTRAL_NPCS, TRUE);

   // * AI: Activating the switch below will make the creaures using the WalkWaypoint function
   // * able to walk across areas
   // SetModuleSwitch (MODULE_SWITCH_ENABLE_CROSSAREA_WALKWAYPOINTS, TRUE);

   // * Spells: Activating the switch below will make the Glyph of Warding spell behave differently:
   // * The visual glyph will disappear after 6 seconds, making them impossible to spot
   // SetModuleSwitch (MODULE_SWITCH_ENABLE_INVISIBLE_GLYPH_OF_WARDING, TRUE);

   // * Craft Feats: Want 50 charges on a newly created wand? We found this unbalancing,
   // * but since it is described this way in the book, here is the switch to get it back...
   // SetModuleSwitch (MODULE_SWITCH_ENABLE_CRAFT_WAND_50_CHARGES, TRUE);

   // * Craft Feats: Use this to disable Item Creation Feats if you do not want
   // * them in your module
   // SetModuleSwitch (MODULE_SWITCH_DISABLE_ITEM_CREATION_FEATS, TRUE);

   // * Palemaster: Deathless master touch in PnP only affects creatures up to a certain size.
   // * We do not support this check for balancing reasons, but you can still activate it...
   // SetModuleSwitch (MODULE_SWITCH_SPELL_CORERULES_DMASTERTOUCH, TRUE);

   // * Epic Spellcasting: Some Epic spells feed on the liveforce of the caster. However this
   // * did not fit into NWNs spell system and was confusing, so we took it out...
   // SetModuleSwitch (MODULE_SWITCH_EPIC_SPELLS_HURT_CASTER, TRUE);

    // SetModuleSwitch (MODULE_SWITCH_RESTRICT_USE_POISON_TO_FEAT, TRUE);

    // * Spellcasting: Some people don't like caster's abusing expertise to raise their AC
    // * Uncommenting this line will drop expertise mode whenever a spell is cast by a player
    SetModuleSwitch (MODULE_VAR_AI_STOP_EXPERTISE_ABUSE, TRUE);


    // * Item Event Scripts: The game's default event scripts allow routing of all item related events
    // * into a single file, based on the tag of that item. If an item's tag is "test", it will fire a
    // * script called "test" when an item based event (equip, unequip, acquire, unacquire, activate,...)
    // * is triggered. Check "x2_it_example.nss" for an example.
    // * This feature is disabled by default.
   SetModuleSwitch (MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS, TRUE);

   object oArea = GetFirstArea();
   string sAreaResRef;
   location lBaseLocation = Location(GetObjectByTag("_BASE"), Vector(1.0, 1.0, 1.0), 0.0);
   object oAreaRefresher;

// Loop through all objects in the module.
   while (GetIsObjectValid(oArea))
   {
       sAreaResRef = GetResRef(oArea);
// Skip the system areas or copied areas. They are prepended with an underscore.
       if (GetStringLeft(sAreaResRef, 1) == "_")
       {
           oArea = GetNextArea();
           continue;
       }

// create an area refresher if this is an instanced area.
// this object will occasionally check when an area needs to be destroyed
// and then re-create the area
       if (GetLocalInt(oArea, "instance") == 1)
       {
           object oAreaRefresher = CreateObject(OBJECT_TYPE_CREATURE, "_area_refresher", lBaseLocation, FALSE, sAreaResRef+"+_counter");
           SetLocalString(oAreaRefresher, "resref", sAreaResRef);
           SetName(oAreaRefresher, sAreaResRef);
       }

       DelayCommand(0.001, ExecuteScript("area_init", oArea));

       oArea = GetNextArea();
   }

// Treasures cause heavy delay on starting a module
// It can be skipped, but it will cause merchants to lose most of their inventory
// As well as cause no treasure to be generated.
// For testing purposes, we shall skip creating treasures if local/no NWNX.
   if (NWNX_Time_GetTimeStamp() > 0)
   {
        DelayCommand(0.0, ExecuteScript("gtreas_start", OBJECT_SELF));
   }
   else
   {
        SetEventScript(GetModule(), EVENT_SCRIPT_MODULE_ON_HEARTBEAT, "on_mod_heartb");
   }
}
