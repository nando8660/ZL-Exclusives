--Compulsory Teleportation
local s,id=GetID()
function s.initial_effect(c)
	--Can be activated from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e1)
    	--Special Summon from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_DECK+LOCATION_HAND)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    return not (Duel.GetTurnPlayer()==tp) and (Duel.GetTurnCount()==1 or (not Duel.GetFlagEffect(tp, 109)==0) or c:IsLocation(LOCATION_SZONE))
        and Duel.GetMatchingGroupCount(s.filter1, tp, 0, LOCATION_HAND, nil)>0 and Duel.GetCurrentChain(true)>0
end
function s.filter1(c)
    return c:IsAbleToDeck()
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    return (Duel.GetMatchingGroup(s.filter1, tp, 0, LOCATION_HAND, nil)) or (Duel.GetMatchingGroup(s.filter2, tp, 0, LOCATION_HAND, nil))
end
function s.filter2(c, e, tp)
    return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, 1-tp, false, false)
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    if c:IsPreviousLocation(LOCATION_DECK) then
        Duel.ShuffleDeck(tp)
    else
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
    local gm = Duel.GetMatchingGroup(s.filter2, 1-tp, LOCATION_HAND, 0, nil, e, 1-tp)
    if #gm==0 or Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0)==5 or not Duel.IsPlayerCanSpecialSummon(1-tp) then
        local gh = Duel.GetFieldGroup(tp, 0, LOCATION_HAND)
        Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)
        local td=gh:RandomSelect(1-tp,1)
        Duel.SendtoDeck(td,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    else
        Duel.ConfirmCards(tp, gm)
        Duel.Hint(HINTMSG_SELECT, tp, HINTMSG_SPSUMMON)
        local tg = Group.Select(gm, tp, 1, 1, nil, e, tp)
        Duel.SpecialSummonStep(tg:GetFirst(), SUMMON_TYPE_SPECIAL, 1-tp, tp, false, false, POS_FACEUP_DEFENSE)
        local tc=tg:GetFirst()
        -- Halve status
        local atk=tc:GetBaseAttack()
        local def=tc:GetBaseDefense()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK)
        e1:SetValue(atk/2)
        e1:SetReset(RESET_EVENT)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_SET_DEFENSE)
        e2:SetValue(def/2)
        tc:RegisterEffect(e2)
        --Cannot activate effects
        local e5=Effect.CreateEffect(c)
        e5:SetType(EFFECT_TYPE_SINGLE)
        e5:SetCode(EFFECT_CANNOT_TRIGGER)
        e5:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e5)
        --Banish it if it leaves the field
        local e7=Effect.CreateEffect(c)
        e7:SetDescription(3300)
        e7:SetType(EFFECT_TYPE_SINGLE)
        e7:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
        e7:SetReset(RESET_EVENT+RESETS_REDIRECT)
        e7:SetValue(LOCATION_REMOVED)
        tc:RegisterEffect(e7)
        Duel.SpecialSummonComplete()
    end
end
