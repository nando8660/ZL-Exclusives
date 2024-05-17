-- Automatic Storage Manager
-- Aeon Storage Automatic Manager
local s,id=GetID()
function s.initial_effect(c)
    --Treated as a "Makina-vice" while on the deck/hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetValue(0x21E0)
	c:RegisterEffect(e1)
	-- SS itself and a Crystalized "Makina-vice"
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(function(e) return e:GetHandler():IsContinuousSpell() end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- Shuffle EARTH Machines if sent from field to GY
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.tdcon)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	--Can be treated as "Makina-vice Monster A" for a fusion summon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CHANGE_CODE)
	e4:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e4:SetOperation(s.chngcon)
	e4:SetValue(632467022)
	c:RegisterEffect(e4)
end
function s.filter1(c,e,tp)
	return c:IsSetCard(0x21E0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter2(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_SZONE,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_SZONE)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	if not e:GetHandler():IsRelateToEffect(e) or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_SZONE,0,1,1,e:GetHandler(),e,tp)
	if #g>0 then
		g:AddCard(e:GetHandler())
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp, s.filter2, LOCATION_GRAVE, 1, 0, 1, 2, true, e, tp)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.chngcon(scard,sumtype,tp)
	return (sumtype&MATERIAL_FUSION)~=0
end
