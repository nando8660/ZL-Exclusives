-- Shadow Lizzard
-- Un-quietness Shadow Anolis
local s,id=GetID()
function s.initial_effect(c)
	-- Normal summon 1 "Un-quietness" monster from hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_HANDES+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.sumcost)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	-- Revive
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_LEAVE_GRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.sumfilter(c)
    return c:IsSummonable(true, e) and c:IsSetCard(0x21e1) and not c:IsAttribute(ATTRIBUTE_DARK)
end
function s.sumtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter, tp, LOCATION_HAND, 0, 1, nil) 
        and Duel.IsPlayerCanSummon(tp) end
end
function s.sumop(e, tp, eg, ep, ev, re, r, rp)
    local tc=Duel.SelectMatchingCard(tp, s.sumfilter, tp, LOCATION_HAND, 0, 1, 1, nil):GetFirst()
    Duel.Summon(tp, tc, true, nil)
end
function s.revivefilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsSetCard(0x21e1) and not c:IsAttribute(ATTRIBUTE_DARK)
end
function s.banfilter(c,e)
	return c:IsCode(id) and c:IsFaceup() and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) and s.revivefilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.revivefilter,tp,LOCATION_MZONE,0,1,nil)
        	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.revivefilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local g=Duel.GetMatchingGroup(s.banfilter, tp, LOCATION_GRAVE, 0, e:GetHandler())
    Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
    if e:GetHandler():IsLocation(LOCATION_GRAVE) and Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP) then
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e:GetHandler():RegisterEffect(e1,true)
        Duel.BreakEffect()
        local num=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,nil):GetBinClassCount(Card.GetAttribute)
        if num>3 then
            if Duel.Recover(tp, 800, REASON_EFFECT) then
                Duel.Draw(tp, 1, REASON_EFFECT)
            end
        end
    end
end
