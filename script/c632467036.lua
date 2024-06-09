-- Watcher Sporebulb
-- Un-quietness Day Sporebulb
local s,id=GetID()
function s.initial_effect(c)
	-- Discard if added to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(function(e) return not e:GetHandler():IsReason(REASON_DRAW) end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_DISCARD) end)
	c:RegisterEffect(e1)
	-- If normal summoned
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.cost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	-- Revive
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_LEAVE_GRAVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY) 
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(s.revcon)
	e3:SetOperation(s.revoperation)
	c:RegisterEffect(e3)
end
function s.costfilter(c, e, tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x21e1) and not c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.PayLPCost(tp,500)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(s.drcon)
	e1:SetOperation(s.drop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1, tp)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp and re and re:GetHandler() then
		return re:GetHandler():IsSetCard(0x21e1)
	end
	return false
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Draw(tp,1,REASON_EFFECT)
end
function s.cfilter(c,tp)
	return c:IsSetCard(0x21e1) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and not c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.cfilter,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
end
function s.banfilter(c,e)
	return c:IsCode(id) and c:IsFaceup() and c:IsAbleToRemove()
end
function s.revoperation(e, tp, eg, ep, ev, re, r, rp)
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
