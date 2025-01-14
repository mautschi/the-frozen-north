#include "inc_persist"
#include "inc_debug"
#include "inc_henchman"
#include "inc_quest"
#include "nwnx_util"
#include "inc_sql"
#include "inc_general"
#include "nwnx_time"

void DoRevive(object oDead)
{
        if (GetIsInCombat(oDead)) return;
        if (GetIsDead(oDead))
        {
            SendDebugMessage(GetName(oDead)+" is dead, start revive loop");
            int bEnemy = FALSE;
            int bFriend = FALSE;
            int bMasterFound = FALSE;
            int nFaction;

            object oMaster = GetMasterByUUID(oDead);
            int bMasterDead = GetIsDead(oMaster);

            location lLocation = GetLocation(oDead);

            float fSize = 30.0;

            float fMasterDistance = GetDistanceBetween(oDead, oMaster);
            if (fMasterDistance <= 90.0) bMasterFound = TRUE;

            if (GetArea(oMaster) != GetArea(oDead)) bMasterFound = FALSE;

            object oCreature = GetFirstObjectInShape(SHAPE_SPHERE, fSize, lLocation, TRUE, OBJECT_TYPE_CREATURE);

            while (GetIsObjectValid(oCreature))
            {
// do not count self and count only if alive
                if (!GetIsDead(oCreature) && (oCreature != oDead))
                {
                    if (GetIsEnemy(oCreature, oDead))
                    {
                        bEnemy = TRUE;
                        SendDebugMessage("Enemy detected, breaking from revive loop: "+GetName(oCreature));
                        break;
                    }
                    else if (!bFriend && GetIsFriend(oCreature, oDead) && !GetIsInCombat(oCreature))
                    {
                        bFriend = TRUE;
                        SendDebugMessage("Friend detected: "+GetName(oCreature));
                    }
                    else if (!bFriend && !GetIsInCombat(oCreature) && (GetIsFriend(oCreature, oDead) || GetIsNeutral(oCreature, oDead)))
                    {
                        nFaction = NWNX_Creature_GetFaction(oCreature);

                        if (nFaction == STANDARD_FACTION_COMMONER || nFaction == STANDARD_FACTION_DEFENDER || nFaction == STANDARD_FACTION_MERCHANT)
                        {
                            bFriend = TRUE;
                            SendDebugMessage("Commoner/Defender/Merchant detected: "+GetName(oCreature));
                        }
                    }

                }

                oCreature = GetNextObjectInShape(SHAPE_SPHERE, fSize, lLocation, TRUE, OBJECT_TYPE_CREATURE);
            }

            if (GetStringLeft(GetResRef(oDead), 3) == "hen" && bMasterFound && !bMasterDead) bFriend = TRUE;

            if (!bEnemy && bFriend && IsCreatureRevivable(oDead))
            {
                SQLocalsPlayer_DeleteInt(oDead, "DEAD");
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oDead);

                DetermineDeathEffectPenalty(oDead, 1);

                if (GetStringLeft(GetResRef(oDead), 3) == "hen" && bMasterFound) SetMaster(oDead, oMaster);
                WriteTimestampedLogEntry(GetName(oDead)+" was revived by friendly "+GetName(oCreature)+".");
            }

// destroy henchman if still not alive and master isn't found
            if (!GetIsPC(oDead) && GetIsDead(oDead) && GetStringLeft(GetResRef(oDead), 3) == "hen" && !bMasterFound)
            {
                 ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_RESTORATION), lLocation);
                 ClearMaster(oDead);
                 DestroyObject(oDead);
            }
        }
}


void main()
{
    object oPC = GetFirstPC();

    ExportAllCharacters();

    string sBounties = GetLocalString(GetModule(), "bounties");

    if (GetIsObjectValid(oPC))
    {
        int nTickCount = NWNX_Util_GetServerTicksPerSecond();
        if (nTickCount <= 50) SendDebugMessage("Low tick count detected: "+IntToString(nTickCount), TRUE);
    }

    int nTime = NWNX_Time_GetTimeStamp();

    while(GetIsObjectValid(oPC))
    {
        DoRevive(oPC);

        RefreshCompletedBounties(oPC, nTime, sBounties);

        if (!GetIsDead(oPC))
            SQLocalsPlayer_DeleteInt(oPC, "DEAD");

        SavePCInfo(oPC);

        oPC = GetNextPC();
    }

    DoRevive(GetObjectByTag("hen_tomi"));
    DoRevive(GetObjectByTag("hen_daelan"));
    DoRevive(GetObjectByTag("hen_sharwyn"));
    DoRevive(GetObjectByTag("hen_linu"));
}
