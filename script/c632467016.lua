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
	-- Shuffle 1 "EonTech ASSEMBLY PROCEDURE" from your GY into the deck
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep) return ep==1-tp end)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
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
function s.filter2(c,e)
	return c:IsCode(632467013) and c:IsAbleToDeck()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local th=e:GetHandler()
	local td=Duel.SelectMatchingCard(tp, s.filter2, tp, LOCATION_GRAVE, 0, 1, 1)
	if th:IsRelateToEffect(e) then
		Duel.SendtoHand(th,nil,REASON_EFFECT)
	end
	Duel.SendtoDeck(td, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
end
