-- Detonitrium Cohete del Lunobloqueo
local s,id=GetID()
function s.initial_effect(c)
    --fusion material
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c, true, true, 632467022,1,632467024,1)
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
    e2:SetProperty(EFFECT_FLAG_DELAY)
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
        special_cases = (c_seq == 5 and same_controller) --or (c_seq==6 and not same_controller)
    elseif h_seq == 3 then
        special_cases = (c_seq == 6 and same_controller) --or (c_seq==5 and not same_controller)
    elseif h_seq == 5 then
        special_cases = c_seq == 1 and same_controller
    elseif h_seq == 6 then
        special_cases = c_seq == 3 and same_controller
    end
    return (horizontal_adj and same_controller) or (same_sequence and same_controller) or (special_cases and c:IsLocation(LOCATION_MZONE))
end
function s.filter1(c, e)
    return c:IsType(TYPE_MONSTER)
end
function s.filter2(c, e)
    return not c:IsType(TYPE_MONSTER)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(), e)
    if Duel.Destroy(e:GetHandler(),REASON_EFFECT) and g:GetCount()>0 then
        Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
        -- local og=Duel.GetOperatedGroup()
	local og=g
        local g1=og:Filter(s.filter1,nil,e)
        local g2=og:Filter(s.filter2,nil,e)
        local tc1=og:GetFirst()
        local tc2=og:GetFirst()
        for tc1 in aux.Next(g1) do
            --Cannot change their battle positions
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(id,0))
            e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,1)
            tc1:RegisterEffect(e1)
        end
        for tc2 in aux.Next(g2) do
            --It cannot be activated this turn
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(id,0))
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetCode(EFFECT_CANNOT_TRIGGER)
            e1:SetReset(RESET_EVENT|RESETS_CANNOT_ACT|RESET_PHASE|PHASE_END)
            tc2:RegisterEffect(e1)
        end
    end
end
