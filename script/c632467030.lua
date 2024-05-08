-- Tempor-Ax Industries INC
-- EonTech Corporation - Aeon Facility INC
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- Shuffle all machines from the GY
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
function s.thfilter(c)
	return (c:IsSetCard(0x21DE) or c:IsSetCard(0x21E0)) and c:IsMonster() and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.filter1(c,e)
	return c:IsRace(RACE_MACHINE)
end
function s.filter2(c,e)
	return c:IsSetCard(0x21df) or c:IsSetCard(0x21E0) and c:IsMonster()
end
function s.filter3(c,e)
	return c:IsSetCard(0x21df) or c:IsSetCard(0x21E0) and c:IsMonster() and c:IsLocation(LOCATION_DECK|LOCATION_EXTRA)
end
function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter1, tp, LOCATION_GRAVE, 0, 1, nil) end
end
function s.tdop(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetMatchingGroup(s.filter1, tp, LOCATION_GRAVE, 0, nil, e)
	if #g==0 then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local og = Duel.GetOperatedGroup():Filter(s.filter3,nil,e)
	if #og>=2 then
		Duel.Draw(tp, 2, REASON_EFFECT)
	end
end