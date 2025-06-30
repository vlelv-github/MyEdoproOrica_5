-- 죽음을 부르는 위저 보드
local s,id=GetID()
function s.initial_effect(c)
    -- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    -- 2번 효과
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
	e4:SetTarget(s.actg)
	e4:SetOperation(s.acop)
	c:RegisterEffect(e4)
end
    -- "위저 보드", 자신의 카드명이 쓰여짐
s.listed_names = {CARD_DESTINY_BOARD, id}

function s.thcostfilter(c)
    return c:IsDiscardable() and c:IsMonster() and (c:IsRace(RACE_FIEND) or c:IsRace(RACE_ZOMBIE))
end

function s.boardfilter(c)
    return c:IsCode(CARD_DESTINY_BOARD) and c:IsFaceup()
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,s.thcostfilter,1,1,REASON_COST|REASON_DISCARD)
end
function s.thfilter(c, inst)
	return ((c:IsMonster() and c:ListsCode(CARD_DESTINY_BOARD))
		or ( (inst and c:IsSpellTrap() and c:ListsCode(CARD_DESTINY_BOARD) and not c:IsCode(id)) or (c:IsCode(CARD_DESTINY_BOARD)) ))
		and c:IsAbleToHand()
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsMonster,nil)==1
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local inst = false
    if Duel.IsExistingMatchingCard(s.boardfilter,tp,LOCATION_ONFIELD,0,1,nil) then
        inst = true
    end
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,inst)
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local inst = false
    if Duel.IsExistingMatchingCard(s.boardfilter,tp,LOCATION_ONFIELD,0,1,nil) then
        inst = true
    end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,inst)
	if #g<2 then return end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	if #rg>0 then
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,rg)
	end
end

function s.actfilter(c,tp)
	return c:IsCode(CARD_DESTINY_BOARD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_HAND,0,1,nil,tp) end
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local tc=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then
			cost(te,tep,eg,ep,ev,re,r,rp,1)
		end
	end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetTargetRange(LOCATION_ONFIELD,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_DESTINY_BOARD))
    e1:SetValue(s.efilter)
    Duel.RegisterEffect(e1,tp)
    aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2))
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end