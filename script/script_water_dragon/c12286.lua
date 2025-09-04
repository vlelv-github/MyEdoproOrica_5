-- 본딩 라보
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetValue(s.effval)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.sccon)
	e3:SetCost(s.sccost)
	e3:SetTarget(s.sctg)
	e3:SetOperation(s.scop)
	c:RegisterEffect(e3)
end

-- "듀테리온", "하이드로게돈", "옥시게돈", "워터 드래곤", 이 카드의 카드명이 쓰여짐
s.listed_names = {22587018, 58071123, 43017476, 85066822, id}
-- "본딩"의 테마명이 쓰여짐
s.listed_series={SET_BONDING}
function s.filter(c)
	return c:IsCode(85066822) or (c:IsRace(RACE_DINOSAUR) and c:IsAttribute(ATTRIBUTE_WATER|ATTRIBUTE_WIND)) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE|LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
	
end

function s.effval(e,ct)
	local trig_p,trig_typ,setcodes=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_TYPE,CHAININFO_TRIGGERING_SETCODES)
	if not (trig_p==e:GetHandlerPlayer() and (trig_typ&TYPE_FUSION)>0) then return false end
	for _,set in ipairs(setcodes) do
		if (SET_MELODIOUS&0xfff)==(set&0xfff) and (SET_MELODIOUS&set)==SET_MELODIOUS then return true end
	end
end

function s.effval(e,ct)
	local trig_e,trig_p,trig_loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	if not (trig_p==e:GetHandlerPlayer() and (trig_loc&LOCATION_MZONE)>0) then return false end
	local trig_c=trig_e:GetHandler()
	return trig_c:IsRace(RACE_DINOSAUR|RACE_SEASERPENT)
end

function s.scfilter(c,tp)
	return c:IsFaceup() and c:IsCode(22587018, 58071123, 43017476) and c:IsControler(tp)
end
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.scfilter,1,nil,tp)
end
function s.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
end
function s.thsetfilter(c)
	return c:IsSetCard(SET_BONDING) and c:IsSpellTrap() and (c:IsAbleToHand() or c:IsSSetable())
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thsetfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,s.thsetfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function(sc) return sc:IsSSetable() end,
		function(sc) Duel.SSet(tp,sc) end,
		aux.Stringid(id,3)
	)
end