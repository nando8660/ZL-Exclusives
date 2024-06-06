-- Stray Wings
-- Un-quietness Everstray
local s,id=GetID()
function s.initial_effect(c)
	-- if sent to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_DECK) end)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- Revive
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_LEAVE_GRAVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(s.target1)
	e3:SetOperation(s.operation1)
	c:RegisterEffect(e3)

end
function s.costfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x21e1) and c:IsAbleToGraveAsCost() and not c:IsAttribute(ATTRIBUTE_WIND)
end
function s.banfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemove()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.PayLPCost(tp,500)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.banfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local g=Duel.SelectMatchingCard(tp, s.banfilter, tp, LOCATION_HAND+LOCATION_MZONE, 0, 1, 1, nil)
    local tc=g:GetFirst()
    if tc then
        Duel.Remove(tc, POS_FACEUP, REASON_EFFECT)
        -- LP Gain
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- e1:SetCategory(CATEGORY_RECOVER)
        e1:SetCondition(function(e,tp) return e:GetHandler():IsControler(tp) end)
        e1:SetTarget(s.lptg)
        e1:SetOperation(s.lpop)
        e1:SetReset(RESET_EVENT+RESET_TURN_SET+RESET_LEAVE+RESET_TODECK+RESET_TOHAND+RESET_REMOVE+RESET_TEMP_REMOVE+RESET_TOGRAVE)
        Card.RegisterEffect(tc, e1)
    end
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
function s.filter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x21e1) and not c:IsAttribute(ATTRIBUTE_WIND)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.selffilter(c,e)
	return c:IsCode(id) and c:IsAbleToRemove()
end
function s.banfilter2(c,e)
	return c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end
function s.operation1(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.GetMatchingGroup(s.selffilter, tp, LOCATION_GRAVE, 0, e:GetHandler())
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
		local tuners=Duel.GetMatchingGroup(s.banfilter2, tp, LOCATION_MZONE, 0, e:GetHandler())
		if #tuners>0 then
			Duel.Remove(tuners, POS_FACEDOWN, REASON_EFFECT)
		end
	end
end
