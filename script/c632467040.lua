-- Liberty, the Devourer of Beings
local s,id=GetID()
function s.initial_effect(c)
    --Must be properly summoned before reviving
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	--Special Summon procedure
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA|LOCATION_GRAVE)
	e2:SetCondition(s.sprcon)
	e2:SetTarget(s.sprtg)
	e2:SetOperation(s.sprop)
	e2:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e2)
	-- Gain LP instead of inflicting battle damage
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.reop)
	c:RegisterEffect(e3)
	-- battle indestructable
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	-- Special Summon and negate
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp 
		and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE end)
	e6:SetCost(s.spcost)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
end
-- SUMMON PROC (START)
function s.sprfilter(c)
	return c:IsFaceup() and c:HasLevel() --and c:IsAbleToGraveAsCost()
end
function s.sprfilter1(c,tp,g,sc,e)
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE,0,nil)
	return c:IsType(TYPE_TUNER) and g:IsExists(s.sprfilter2,1,c,tp,c,sc,e)
end
function s.sprfilter2(c,tp,mc,sc,e)
	local sg=Group.FromCards(c,mc)
	local THIS_CARD_LEVEL=e:GetHandler():GetLevel()
	return (math.abs((c:GetLevel()-mc:GetLevel()))==THIS_CARD_LEVEL) and not c:IsType(TYPE_TUNER)-- and Duel.GetLocationCountFromEx(tp,tp,sg,sc)>0
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE,0,nil)
	return g:IsExists(s.sprfilter1,1,nil,tp,g,c,e)
end
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE,0,nil)
	local g1=g:Filter(s.sprfilter1,nil,tp,g,c,e)
	local mg1=aux.SelectUnselectGroup(g1,e,tp,1,1,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #mg1>0 then
		local mc=mg1:GetFirst(	)
		local g2=g:Filter(s.sprfilter2,mc,tp,mc,c,e,mc:GetLevel())
		local mg2=aux.SelectUnselectGroup(g2,e,tp,1,1,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
		mg1:Merge(mg2)
	end
	if #mg1==2 then
		mg1:KeepAlive()
		e:SetLabelObject(mg1)
		return true
	end
	return false
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g, REASON_COST)
end
-- SUMMON PROC (END)
-- Batte Damage (Start)
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp and Duel.Recover(tp, ev, REASON_EFFECT) then Duel.ChangeBattleDamage(1-tp, 0) end
end
-- Battle Damage (End)
-- Special Summon and Negate (Start)
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	Duel.PayLPCost(tp,800)
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.disfilter(c,e,tp,att)
	return c:IsMonster() and c:IsCanBeEffectTarget(e) and c:IsAttribute(att)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,e,tp)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)~=0 then
		local g2=Duel.GetMatchingGroup(s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp,tc:GetAttribute())
		if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
			local tc2=g2:Select(tp,1,1,nil):GetFirst()
			if tc2 then
				-- Negate its effects
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc2:RegisterEffect(e1,true)
				-- Banish when leaves the field
				local e2=Effect.CreateEffect(c)
				e2:SetDescription(3300)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
				e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e2:SetValue(LOCATION_REMOVED)
				e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
				tc2:RegisterEffect(e2,true)
			end
		end
	end
end
