-- 저주의 사악령
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfToGrave)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.cond)
	e3:SetTarget(s.tftg)
	e3:SetOperation(s.tfop)
	c:RegisterEffect(e3)
end
    -- "위저 보드", 자신의 카드명이 쓰여짐
s.listed_names = {CARD_DESTINY_BOARD, id}
    -- "죽음의 메시지"의 테마명이 쓰여짐
s.listed_series = {CARDS_SPIRIT_MESSAGE}


function s.thfilter(c)
	return (c:ListsCode(CARD_DESTINY_BOARD) or c:IsCode(30170981) or c:IsCode(67287533) or c:IsCode(94772232) or c:IsCode(31893528)) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.cond(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsOnField() and (re:GetHandler():IsCode(CARD_DESTINY_BOARD) and not re:IsHasType(EFFECT_TYPE_ACTIVATE))
end

function s.smfilter(c)
	return c:IsCode(table.unpack(CARDS_SPIRIT_MESSAGE)) and not c:IsForbidden()
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if chk==0 then return e:GetHandler():IsAbleToHand() 
		and ft>0 and Duel.IsExistingMatchingCard(s.smfilter,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		if Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)~=0 then 
			if Duel.IsPlayerAffectedByEffect(tp,CARD_DARK_SANCTUARY) then return s.extraop(e,tp,eg,ep,ev,re,r,rp) end
			if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.smfilter),tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
			if #g>0 then
				Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			end
		end
	end
end

function s.extraop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.smfilter),tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if not tc then return end
	if Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER|TYPE_NORMAL,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,tp,181)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.GetLocationCount(tp,LOCATION_SZONE)<1
		or Duel.SelectYesNo(tp,aux.Stringid(CARD_DARK_SANCTUARY,0))) then
			tc:AddMonsterAttribute(TYPE_NORMAL,ATTRIBUTE_DARK,RACE_FIEND,1,0,0)
			Duel.SpecialSummonStep(tc,181,tp,tp,true,false,POS_FACEUP)
			tc:AddMonsterAttributeComplete()
			--immune
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetValue(s.efilter)
			e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
			tc:RegisterEffect(e1)
			--cannot be target
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT|RESETS_REDIRECT)
			tc:RegisterEffect(e2)
			Duel.SpecialSummonComplete()
	elseif Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
function s.efilter(e,te)
	local tc=te:GetHandler()
	return not tc:IsCode(CARD_DESTINY_BOARD)
end