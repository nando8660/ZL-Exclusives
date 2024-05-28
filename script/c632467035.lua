-- Ashen Panter
-- Un-quietness Ashen Thera
local s,id=GetID()
function s.initial_effect(c)
	-- Discard if added to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCost(s.sumlimitcost)
	e1:SetCondition(function(e) return not e:GetHandler():IsReason(REASON_DRAW) end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) if Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_DISCARD) 
		then Duel.Recover(tp, 200, REASON_EFFECT) end end)
	c:RegisterEffect(e1)
	-- SSummon from deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCost(s.sumlimitcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- Revive
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_LEAVE_GRAVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(s.sumlimitcost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
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
function s.spfilter(c,e,tp)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x21e1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x21e1) and not c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.banfilter(c,e)
    return c:IsCode(1) and c:IsAbleToRemove()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) 
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
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
    end
end