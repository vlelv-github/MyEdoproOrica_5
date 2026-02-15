-- 행복을 안겨주는 운명
local s,id=GetID()
function s.initial_effect(c)

    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(Cost.SelfBanish)
    e2:SetCondition(s.sumcon)
    e2:SetTarget(s.sumtg)
    e2:SetOperation(s.sumop)
    c:RegisterEffect(e2)
end
s.listed_series = {SET_FORTUNE_LADY,SET_FORTUNE_FAIRY}
function s.rmvfilter(c)
    return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemove() 
        and ((c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) or c:IsLocation(LOCATION_HAND|LOCATION_GRAVE))
end

function s.thfilter(c,lv)
    return c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(lv) and c:IsAbleToHand()
end
function s.thfilter2(c,lv)
    return c:IsRace(RACE_SPELLCASTER) and c:IsLevel(lv) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local rg=Duel.GetMatchingGroup(s.rmvfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    local b=#rg>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,#rg)
    if chk==0 then
        return b
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.rescon(sg,e,tp,mg)
	return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,#sg)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local rg=Duel.GetMatchingGroup(s.rmvfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    if #rg==0 then return end
    local rmg=aux.SelectUnselectGroup(rg,e,tp,1,#rg,s.rescon,1,tp,HINTMSG_REMOVE,s.rescon)
    if #rmg>0 and Duel.Remove(rmg,POS_FACEUP,REASON_EFFECT)>0 then 
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil,#rmg)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end

   --Cannot Special Summon from the Extra Deck, except Synchro monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,function(_,c) return not c:IsOriginalType(TYPE_SYNCHRO) end)
	
end

function s.cost_fortunelady(c)
    return c:IsSetCard(SET_FORTUNE_LADY) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end

function s.hand_wizard(c,e,tp)
    return c:IsRace(RACE_SPELLCASTER) and (c:IsSummonable(true,nil) or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.hand_wizard_sm(c)
    return c:IsSummonable(true,nil)
end
function s.hand_wizard_spsm(c,e,tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:IsAbleToRemoveAsCost()
            and Duel.IsExistingMatchingCard(s.cost_fortunelady,tp,LOCATION_GRAVE,0,1,c)
            and Duel.IsExistingMatchingCard(s.hand_wizard,tp,LOCATION_HAND,0,1,nil,e,tp)
    end
    Duel.Remove(c,POS_FACEUP,REASON_COST)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.cost_fortunelady,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local rc=Duel.SelectMatchingCard(tp,s.hand_wizard,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
    Duel.ConfirmCards(1-tp,rc)
    Duel.SetTargetCard(rc)
end

function rfilter(c)
    return (c:IsSetCard(SET_FORTUNE_LADY) or c:IsSetCard(SET_FORTUNE_FAIRY)) and c:IsMonster() and c:IsAbleToRemove()
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_MZONE,0,2,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,0,nil)
    if #g<2 then return end
    local gg = g:Select(tp,2,99,nil)
    if Duel.Remove(gg,0,REASON_EFFECT|REASON_TEMPORARY)~=0 then 
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
		e1:SetReset(RESET_PHASE|PHASE_STANDBY)
		e1:SetLabelObject(gg)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)

        Duel.BreakEffect()
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE|PHASE_BATTLE_STEP,1)
    end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local rg=e:GetLabelObject()
    for tc in rg:Iter() do
		Duel.ReturnToField(tc)
	end
end