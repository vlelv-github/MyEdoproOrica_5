-- 트랩 크러시
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_JINZO}
s.listed_series={SET_JINZO}
function s.filter1(c)
	return c:IsFacedown()
end
function s.filter2_1(c,tp)
	return c:IsTrap() and c:IsSSetable(false,1-tp)
end
function s.filter2_2(c)
	return (c:IsSetCard(SET_JINZO) or c:ListsCode(CARD_JINZO)) and c:IsMonster() and c:IsAbleToHand()
end
function s.filter3_1(c)
	return c:IsCode(CARD_JINZO) and c:IsFaceup()
end
function s.filter3_2(c)
	return c:IsMonster() and c:IsFaceup() and c:IsControlerCanBeChanged()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(s.filter1,tp,0,LOCATION_ONFIELD,1,nil)
	local b2=not Duel.HasFlagEffect(tp,id+2)
		and Duel.IsExistingMatchingCard(s.filter2_1,tp,LOCATION_DECK,0,1,nil,tp)
	local b3=not Duel.HasFlagEffect(tp,id+3)
		and Duel.IsExistingMatchingCard(s.filter3_1,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.filter3_2,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)},
		{b3,aux.Stringid(id,2)})
	e:SetLabel(op)
	Duel.RegisterFlagEffect(tp,id+op,RESET_PHASE|PHASE_END,0,1)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
        local g=Duel.GetMatchingGroup(s.filter1,tp,0,LOCATION_ONFIELD,nil)
	    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==3 then
		e:SetCategory(CATEGORY_CONTROL)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,tp,0)
	end
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		local g=Duel.GetMatchingGroup(s.filter1,tp,0,LOCATION_ONFIELD,nil)
	    Duel.Destroy(g,REASON_EFFECT)
	elseif op==2 then
		local g=Duel.SelectMatchingCard(tp,s.filter2_1,tp,LOCATION_DECK,0,1,1,nil,tp)
        if Duel.SSet(tp,g,1-tp)>0 then 
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g=Duel.SelectMatchingCard(tp,s.filter2_2,tp,LOCATION_DECK,0,1,2,nil)
            if #g>0 then
                Duel.SendtoHand(g,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g)
            end
        end
    elseif op==3 then
		local cg=Duel.GetMatchingGroup(s.filter3_2,tp,0,LOCATION_MZONE,nil)
	    if #cg==0 then return end
        local rg=Duel.GetMatchingGroup(s.filter3_1,tp,LOCATION_MZONE,0,nil)
	    if #rg==0 then return end
        local sg=cg:Select(tp,1,math.min(#rg, #cg),nil)
        
        if #sg>0 then 
            for sc in aux.Next(sg) do
                -- 컨트롤 탈취
                Duel.GetControl(sc,tp)
                -- 레벨은 6
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_CHANGE_LEVEL)
                e1:SetValue(6)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                sc:RegisterEffect(e1)
            end
            -- 다음 턴의 엔드 페이즈에 제외됨
            local turn_ct=Duel.GetTurnCount()
            aux.DelayedOperation(sg,PHASE_END,id,e,tp,
                function(ag)
                    Duel.Remove(ag,POS_FACEUP,REASON_EFFECT)
                end,
                function()
                    return Duel.GetTurnCount()==turn_ct+1
                end,
                nil,2
            )
        end
	end
end