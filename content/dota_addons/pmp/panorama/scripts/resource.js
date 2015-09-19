"use strict";

GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false );
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER, false );
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, false );
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false );
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY, false );

function OnPlayerLumberChanged ( args ) {
	var iPlayerID = Players.GetLocalPlayer()
	var lumber = args.lumber
	//$.Msg("Player "+iPlayerID+" Lumber: "+lumber)
	$('#LumberText').text = lumber
	CheckHudFlipped();
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

	if (Game.IsHUDFlipped())
	{
		$.Msg('LoL Player detected, Flipping Panels... ')
		lumberPanel.RemoveClass( "Right" );
		foodPanel.RemoveClass( "Right" );
		lumberPanel.AddClass( "Flipped" );
		foodPanel.AddClass( "Flipped" );	
	}
	else
	{
		lumberPanel.RemoveClass( "Flipped" );
		foodPanel.RemoveClass( "Flipped" );
		lumberPanel.AddClass( "Right" );
		foodPanel.AddClass( "Right" );	
	}
}

(function () {
	GameEvents.Subscribe( "player_lumber_changed", OnPlayerLumberChanged );
	GameEvents.Subscribe( "player_food_changed", OnPlayerFoodChanged );
})();