-- 에지임프 체인쏘우
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2,s.matcheck)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)

    local params={function(c) return c:IsSetCard(SET_FRIGHTFUR) end}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e2:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e2)
end
s.listed_names = {70245411}
s.listed_series = {SET_FLUFFAL, SET_EDGE_IMP, SET_FRIGHTFUR}
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(s.matfunc,1,nil,nil,lc,sumtype,tp)
end
function s.matfunc(c,lc,sumtype,tp)
    return c:IsSetCard(SET_FLUFFAL,lc,sumtype,tp) or c:IsSetCard(SET_EDGE_IMP,lc,sumtype,tp)
end
function s.plfilter(c,tp)
    return not c:IsForbidden() and c:CheckUniqueOnField(tp) and c:IsCode(70245411)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp) end
end
function s.tdfilter(c)
	return c:IsSetCard(SET_FLUFFAL) and c:IsMonster()
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if sc and Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_DECK,0,1,nil)
    and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_DECK,0,1,1,nil)
        local tc=g:GetFirst()
        if tc then
            Duel.BreakEffect()
            Duel.ShuffleDeck(tp)
            Duel.MoveSequence(tc,0)
            Duel.ConfirmDecktop(tp,1)
        end
	end
end

