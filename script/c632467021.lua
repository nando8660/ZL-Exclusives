-- Bombex monstro A
-- Detonitrium Cohete del Incendio
local s,id=GetID()
function s.initial_effect(c)
    --fusion material
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c, true, true, 632467022,1,632467023,1)
	--Must be Fusion Summoned by a "Tempor-Ax" card effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
    --self destroy on summon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    local e4=e2:Clone()
    e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e4)
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or ((st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and se:GetHandler():IsSetCard(0x21DE))
end
function s.desfilter(c, e, tp)
    local h_seq = e:GetHandler():GetSequence()
    local c_seq = c:GetSequence()
    local same_controller = c:GetControler()==e:GetHandler():GetControler()
    local horizontal_adj = (c_seq == h_seq+1 or c_seq == h_seq-1) and c:GetLocation()==e:GetHandler():GetLocation() and h_seq<5
    local same_sequence = c_seq == h_seq and h_seq<5
    local special_cases = false
    if h_seq == 1 then
        special_cases = (c_seq == 5 and same_controller) or (c_seq==6 and not same_controller)
    elseif h_seq == 3 then
        special_cases = (c_seq == 6 and same_controller) or (c_seq==5 and not same_controller)
    elseif h_seq == 5 then
        special_cases = c_seq == 1
    elseif h_seq == 6 then
        special_cases = c_seq == 3
    end
    return (horizontal_adj and same_controller) or (same_sequence and same_controller) or (special_cases and c:IsLocation(LOCATION_MZONE))
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(), e)
    if Duel.Destroy(e:GetHandler(),REASON_EFFECT) and g:GetCount()>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
