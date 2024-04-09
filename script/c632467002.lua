--Monstro B
--Exhothereal Feral
local s,id=GetID()
function s.initial_effect(c)
	Gemini.AddProcedure(c)
	--Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.selfspcost)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	--Search if gemini summone
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(function(e) return c:IsGeminiState() end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Set Original ATK to 0
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_SET_BASE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(Gemini.EffectStatusCondition)
	e3:SetValue(0)
	c:RegisterEffect(e3)
	--Quick Normal Gemini
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMING_MAIN_END)
	e4:SetCountLimit(1)
	e4:SetCondition(function(e) return c:IsGeminiState() end)
	e4:SetTarget(s.smtg)
	e4:SetOperation(s.smop)
	c:RegisterEffect(e4)
end

function s.rmcfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and ((c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_EFFECT)) or c:IsLocation(LOCATION_HAND)) and Duel.GetMZoneCount(tp,c)>0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and rc:IsSpellTrap() and rc:ListsCardType(TYPE_GEMINI)
end
function s.selfspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmcfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmcfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,e:GetHandler(),tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--Gemini Effect: Search
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoDeck(tg,nil, 1, REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
end
--Search Filter
function s.thfilter(c)
	return c:IsSetCard(0x21d4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
--Normal Summon Filter
function s.filter(c)
	return c:IsType(TYPE_GEMINI) and c:CanSummonOrSet(true,nil)
end

--Gemini Effect: Quick Normal Summon
function s.smtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.smop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end
