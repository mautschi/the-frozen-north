#include "inc_gold"
#include "inc_persist"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_PERSUADE;
    int nDC = 12;

    int nCost = CharismaModifiedPersuadeGold(oPC, 70);

    if (GetGold(oPC) < nCost) return FALSE;

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        TakeGoldFromCreature(nCost, oPC, TRUE);
        SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+GetTag(OBJECT_SELF), 1, 900.0);
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}
