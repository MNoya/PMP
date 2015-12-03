"use strict";

GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false );
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER, false );
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, false );
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false );
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY, false );
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_GOLD, false );

function OnPlayerLumberChanged ( args ) {
	var iPlayerID = Players.GetLocalPlayer()
	var lumber = args.lumber
	//$.Msg("Player "+iPlayerID+" Lumber: "+lumber)
	$('#LumberText').text = lumber
	CheckHudFlipped();
}

function UpdateGold()
{
	var iPlayerID = Players.GetLocalPlayer()
	var gold = Players.GetGold( iPlayerID )
	$('#GoldText').text = gold
	$.Schedule( 0.1, UpdateGold );
}

function UpdateClock()
{
    var DotaTime = Game.GetDOTATime( false, true )
    var Seconds = DotaTime.toFixed(0)
    var Minutes = Math.floor(Seconds / 60)
    Seconds = Seconds % 60
    Minutes = Minutes

    if (Minutes == -1)
    	Minutes = "-0"
    
    var ClockText = Minutes+":"

    if (Math.abs(Seconds) < 10)
    	ClockText = ClockText+"0"

    if (Seconds < 0)
    	ClockText = ClockText+Math.abs(Seconds)
   	else
   		ClockText = ClockText+Seconds 

    $('#ClockTime').text = ClockText;

    $.Schedule( 0.1, UpdateClock );
}

function OnPlayerFoodChanged ( args ) {
	var iPlayerID = Players.GetLocalPlayer()
	var food_used = args.food_used
	var food_limit = args.food_limit
	var race = args.race
	//$.Msg("Player "+iPlayerID+" Food: "+food_used+"/"+food_limit)
	$('#FoodText').text = food_used+"/"+food_limit
	$('#FoodIcon').SetImage( "s2r://panorama/images/custom_game/food_"+race+".png" );
	CheckHudFlipped();
}

function CheckHudFlipped() {
    var lumberPanel = $.FindChildInContext( "#LumberPanel" );
    var foodPanel = $.FindChildInContext( "#FoodPanel" );
    var goldPanel = $.FindChildInContext( "#GoldPanel" );
    var clockPanel = $.FindChildInContext( "#ClockPanel" );

    if (Game.IsHUDFlipped())
    {
        //$.Msg('LoL Player detected, Flipping Panels... ')
        lumberPanel.RemoveClass( "Right" );
        foodPanel.RemoveClass( "Right" );
        goldPanel.RemoveClass( "Right" );
        clockPanel.RemoveClass( "Right" );

        lumberPanel.AddClass( "Flipped" );
        foodPanel.AddClass( "Flipped" );
        goldPanel.AddClass( "Flipped" );
        clockPanel.AddClass( "Flipped" );    
    }
    else
    {
        lumberPanel.RemoveClass( "Flipped" );
        foodPanel.RemoveClass( "Flipped" );
        goldPanel.RemoveClass( "Flipped" );
        clockPanel.RemoveClass( "Flipped" );
        
        lumberPanel.AddClass( "Right" );
        foodPanel.AddClass( "Right" );
        goldPanel.AddClass( "Right" );
        clockPanel.AddClass( "Right" ); 
    }
}

function HighlightResources() {
    var panel = $('#ResourceBox')
    panel.RemoveClass( "Hidden" );
    $.Schedule( 8, function()  { panel.AddClass( "Hidden"  ) }  );
}

(function () {
	UpdateGold();
	UpdateClock();
	CheckHudFlipped();
	GameEvents.Subscribe( "player_lumber_changed", OnPlayerLumberChanged );
	GameEvents.Subscribe( "player_food_changed", OnPlayerFoodChanged );

    GameEvents.Subscribe( "highlight_resource_panel", HighlightResources );
})();