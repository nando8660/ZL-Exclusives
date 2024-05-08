-- Tempor-Ax - The Stellar Core
-- EonTech - The Stellar Core
local s,id=GetID()
function s.initial_effect(c)
    --Treated as a "Tempor-Ax Project Terraform: Stellar Core" while on the deck/hand
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD)
	e0:SetValue(632467015)
	c:RegisterEffect(e0)
	-- Set "BIG FUSION" from the deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCondition(s.setcon)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
end
function s.filter1(c,e)
	return c:IsCode(632467013) and c:IsAbleToHand()
end
function s.setcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetTurnPlayer()==tp
end
function s.setcost(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,c):GetFirst()
	Duel.SendtoDeck(tc, tp, 2, REASON_COST)
end
function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil,tp)
	if tc then
		Duel.SSet(tp,tc:GetFirst())
	end
end