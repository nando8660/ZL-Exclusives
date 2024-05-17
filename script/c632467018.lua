-- Makina-vice Reactor Alpha
-- Hev-Device Reactor Alpha
local s,id=GetID()
function s.initial_effect(c)
    --fusion material
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c, false, false, 632467015,3)
	--Must be Fusion Summoned by a "Tempor-Ax" card effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- Crystalize itself as quick-effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return Duel.IsMainPhase() end)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
	-- Summon itself and draw 1
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e3:SetCondition(function(e,tp) return Duel.IsMainPhase() and e:GetHandler():IsContinuousSpell() and Duel.IsPlayerCanDraw(tp) end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--move
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_ONFIELD)
	e4:SetCountLimit(1,3,EFFECT_COUNT_CODE_CHAIN)
	e4:SetCondition(s.seqcon)
	e4:SetCost(s.seqcost)
	e4:SetTarget(s.seqtg)
	e4:SetOperation(s.seqop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or ((st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and se:GetHandler():IsSetCard(0x21DE))
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>=1 end
end
function s.move_to_stzone(c,hc,tp)
	if not Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then return end
	--Treat as Continuous Spell
	local e1=Effect.CreateEffect(hc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
	c:RegisterEffect(e1)
	return true
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	s.move_to_stzone(c,c,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
end
-- MOVE
function s.spfilter(c,sp)
	return c:GetSummonPlayer()==sp
end
function s.filterPSY(c)
	return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER) and c:IsRace(RACE_PSYCHIC) and c:IsAbleToHand()-- and c:IsSetCard(0x21de)
end
function s.seqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,1-tp)
		and Duel.IsExistingMatchingCard(s.filterPSY,tp,LOCATION_ONFIELD,0,1,nil)		
end
function s.seqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil)
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.seqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(tp) or tc:IsImmuneToEffect(e) or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)>>16,2))
end
