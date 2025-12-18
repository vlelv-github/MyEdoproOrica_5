-- 데스완구 비셔스 폭스
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.mfilter1,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_FLUFFAL))

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.negcon)
    e1:SetCost(s.negcost)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    --Special Summon from hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_EDGE_IMP}
s.listed_names={CARD_POLYMERIZATION}
function s.mfilter1(c,fc,sumtype,tp)
	return c:IsType(TYPE_FUSION,fc,sumtype,tp) or (c:IsSetCard(SET_EDGE_IMP,fc,sumtype,tp))
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.fusionname_filter(c)
    return c:IsCode(CARD_POLYMERIZATION) and c:IsAbleToRemoveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.fusionname_filter,tp,LOCATION_GRAVE,0,nil)
    local can_pay = (#g>0)
    local no_cost_flag = Duel.GetFlagEffect(tp,id)
    if chk==0 then
        return no_cost_flag == 0 or can_pay
    end
    if can_pay then
        local choose_nopay = false
        if no_cost_flag==0 then
            choose_nopay = Duel.SelectYesNo(tp, aux.Stringid(id,0))
        else
            choose_nopay = false
        end

        if choose_nopay then
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
            
        else
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local sg=g:Select(tp,1,1,nil)
            Duel.Remove(sg,POS_FACEUP,REASON_COST)
        end
    else
        if no_cost_flag == 0 then
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        end
    end
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        local rc=re:GetHandler()
        if rc:IsRelateToEffect(re) and rc:IsDestructable() then
            Duel.Destroy(rc,REASON_EFFECT)
        end
    end
end


function s.hspfilter(c,e,tp)
	return c:IsSetCard(SET_FLUFFAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.hspfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.hspfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
        local f=g:GetFirst()
        local val=math.max(f:GetTextAttack(),f:GetTextDefense())
        if val>0 and c:IsRelateToEffect(e) and c:IsFaceup()then 
            c:UpdateAttack(val,RESET_EVENT|RESETS_STANDARD_DISABLE)
        end
    end
end
	