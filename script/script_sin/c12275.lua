-- Sin 패러라이징
local s,id=GetID()
function s.initial_effect(c)
   -- 발동
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkcond)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)


	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(s.effval)
	c:RegisterEffect(e2)
end

	-- "Sin 월드", 자신의 카드명이 쓰여짐
s.listed_names = {27564031, id}
	-- "Sin"의 테마명이 쓰여짐
s.listed_series = {SET_MALEFIC}

function s.thfilter(c)
	return c:IsSSetable() and c:IsSpellTrap() and c:IsSetCard(SET_MALEFIC) and not c:IsCode(id)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=g:Select(tp,1,1,nil)
		Duel.SSet(tp,sg)
	end
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
function s.sinfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MALEFIC)
end
function s.atkcond(e,c)
	return Duel.IsExistingMatchingCard(s.sinfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.atkval(e,c)
	local tatk=0
	local g=Duel.GetMatchingGroup(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		tatk=tatk+tc:GetBaseAttack()
		tc=g:GetNext()
	end
	return -tatk
end

function s.effval(e,ct)
	local trig_p,trig_typ,setcodes,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_TYPE,CHAININFO_TRIGGERING_SETCODES,CHAININFO_TRIGGERING_LOCATION)
	if (loc&LOCATION_ONFIELD)==0 then return false end
	if (trig_typ&TYPE_EFFECT)==0 then return false end
	for _,set in ipairs(setcodes) do
		if (SET_MALEFIC&0xfff)==(set&0xfff) and (SET_MALEFIC&set)==SET_MALEFIC then return true end
	end
end