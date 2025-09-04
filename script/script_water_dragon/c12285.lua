-- 본딩-H3O
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(aux.exccon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end

-- "듀테리온", "하이드로게돈", "옥시게돈"의 카드명이 쓰여짐
s.listed_names = {22587018, 58071123, 43017476}

function s.spcheck(sg,tp,exg,dg)
	return Duel.GetMZoneCount(tp,sg)>=1
end
function s.cfilter(c,e,tp)
	return (c:IsAttribute(ATTRIBUTE_WATER) or c:IsAttribute(ATTRIBUTE_WIND)) and c:IsRace(RACE_DINOSAUR) and c:IsMonster() and c:IsReleasable()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_SEASERPENT) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,3,true,s.spcheck,nil,e,tp) end
	
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,3,3,true,s.spcheck,nil,e,tp)
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    
    local ft=3
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,ft,nil,e,tp)
    if #g>0 then 
        Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
    end
    local spc=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limittg)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetLabel(spc)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	e2:SetValue(s.countval)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2),nil)
end
function s.limittg(e,c,tp)
	local sp=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
	return sp-e:GetLabel()>=1
end
function s.countval(e,re,tp)
	local sp=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
	if sp-e:GetLabel()>=1 then return 0 else return 1-sp+e:GetLabel() end
end

function s.filter(c)
	return c:IsCode(22587018,58071123,43017476) and c:IsMonster() and c:IsAbleToDeck()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,3,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local td=tg:Filter(Card.IsRelateToEffect,nil,e)
	if not tg or #td<=0 then return end
	Duel.SendtoDeck(td,nil,SEQ_DECKTOP,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
	if ct>0 then
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end