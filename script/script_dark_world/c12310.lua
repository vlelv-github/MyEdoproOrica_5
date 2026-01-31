-- 암흑계의 금서
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.cond2)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series = {SET_DARK_WORLD}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if chk==0 then return g:IsExists(Card.IsSetCard,1,e:GetHandler(),SET_DARK_WORLD) and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_DARK_WORLD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    local g=Duel.GetMatchingGroup(Card.IsDiscardable,p,LOCATION_HAND,0,e:GetHandler())
    if g:IsExists(Card.IsSetCard,1,nil,SET_DARK_WORLD) then
        local dk=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
        local dr=math.min(dk-1,#g)
        local sg=aux.SelectUnselectGroup(g,e,p,1,math.min(dr,4),s.rescon,1,p,HINTMSG_DISCARD,s.rescon)
		local disc=Duel.SendtoGrave(sg,REASON_EFFECT|REASON_DISCARD)
        if disc>0 then 
            Duel.Draw(p,disc+1,REASON_EFFECT)
        end
    end
end 

function s.cond2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_HAND) and (r&REASON_EFFECT+REASON_DISCARD)==REASON_EFFECT+REASON_DISCARD
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end