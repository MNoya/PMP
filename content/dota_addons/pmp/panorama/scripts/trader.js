var Root = $.GetContextPanel()

function TradeGold() {
    $.Msg("Trade Gold")

    var PlayerID = Players.GetLocalPlayer();
    GameEvents.SendCustomGameEventToServer( "trade_order", { "PlayerID" : PlayerID, "Type" : "gold" } );
}

function TradeLumber() {
    $.Msg("Trade Lumber")

    var PlayerID = Players.GetLocalPlayer();
    GameEvents.SendCustomGameEventToServer( "trade_order", { "PlayerID" : PlayerID, "Type" : "lumber" } );
}

function OnUpdateSelectedUnit ( event ) {
    Root.AddClass( "Hidden" );
}

function OnUpdateQueryUnit( event )
{
    var iPlayerID = Players.GetLocalPlayer();
    var mainSelected = Players.GetLocalPlayerPortraitUnit();
    if (Entities.GetUnitName(mainSelected) == "trader"){
        $.Msg( "Player "+iPlayerID+" selected Trader" );
        CheckHUDFlipped();
        Root.RemoveClass( "Hidden" );
    }
}

function CheckHUDFlipped () {
    if (Game.IsHUDFlipped())
    {
        //$.Msg('LoL Player detected, Flipping Panels... ')
        Root.RemoveClass( "Right" );
        Root.AddClass( "Flipped" );    
    }
    else
    {
        Root.AddClass( "Right" );
        Root.RemoveClass( "Flipped" );  
    }
}

(function () {
    CheckHUDFlipped();
    GameEvents.Subscribe( "dota_player_update_query_unit", OnUpdateQueryUnit );
    GameEvents.Subscribe( "dota_player_update_selected_unit", OnUpdateSelectedUnit );
})();