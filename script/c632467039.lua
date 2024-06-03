-- Nightmare Cherryblossom
-- Un-quietness Nightmare Tajy
local s,id=GetID()
function s.initial_effect(c)
	-- revive 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(s.combined_costs(s.sumlimitcost,s.spcost))
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- LP Gain 
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.combined_costs(s.sumlimitcost,s.lpcost))
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
	-- Register Special Summons
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(_c) return _c:IsRace(RACE_ZOMBIE) end)
end
-- Summon Limitations
function s.sumlimitcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--Cannot Special Summon, except Zombie monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not c:IsRace(RACE_ZOMBIE) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.combined_costs(cost1,cost2)
	return	function(...)
			local b1,b2=cost1(...),cost2(...)
			return b1 and b2
		end
end
-- Resto
function s.cfilter(c,tp)
	return c:IsSetCard(0x21e1) and not c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true) 
		and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or (c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5))
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.bfilter(c)
	return c:IsCode(id) and c:IsAbleToRemove()
end
function s.spop(e, tp, eg, ep, ev, re, r, rp, chk)
    local g=Duel.GetMatchingGroup(s.bfilter, tp, LOCATION_GRAVE, 0, e:GetHandler(), e)
    Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
    if Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP) then
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e:GetHandler():RegisterEffect(e1,true)
    end
end
function s.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.PayLPCost(tp,1000)
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
function s.lpfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsSummonPlayer(tp)
end
function s.attfilter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
function s.thfilter(c,tp)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x21e1) and c:IsAbleToHand()
		and not Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,c:GetAttribute())
end
function s.lpop(e, tp, eg, ep, ev, re, r, rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.lpfilter, 1, nil, tp) end)
	e1:SetOperation(function(e,tp) Duel.Recover(tp,600,REASON_EFFECT) end)
	e1:SetReset(RESET_PHASE+PHASE_END, 2)
	Duel.RegisterEffect(e1, tp)
	if Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil, tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		local th=Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil, tp)
		Duel.SendtoHand(th, tp, REASON_EFFECT)
	end
end
