"use strict";

var skip = false

var lastClickedEntity = 0;
var clickedCounter = 0;
var pissedThreshold = 1;

function OnUpdateSelectedUnit( event )
{
	if (skip == true){
		skip = false;
		return
	}

	var iPlayerID = Players.GetLocalPlayer();
	var selectedEntities = Players.GetSelectedEntities( iPlayerID );
	var mainSelected = Players.GetLocalPlayerPortraitUnit();

	if (selectedEntities.length > 1 && IsMixedBuildingSelectionGroup(selectedEntities) ){
		//$.Msg( "IsMixedBuildingSelectionGroup, proceeding to deselect the buildings and get only the units ")
		$.Schedule(1/60, DeselectBuildings)	
	}

	$.Schedule(0.03, SendSelectedEntities);

	// Selected sound
    var cursor = GameUI.GetCursorPosition();
    var mouseEntities = GameUI.FindScreenEntities( cursor );

    if (mouseEntities.length > 0)
    {
        for ( var e of mouseEntities )
        {
            if ( !e.accurateCollision )
                continue;
                
            if (Entities.IsControllableByPlayer( e.entityIndex, iPlayerID ))
            {
            	if (e.entityIndex == lastClickedEntity)
            	{
            		clickedCounter++;
	                //$.Msg("Clicked ",clickedCounter," consecutive times on unit ",lastClickedEntity)
	                if (clickedCounter >= pissedThreshold)
	                {
	                    //$.Msg("Send Pissed unit ",e.entityIndex)
	                    GameEvents.SendCustomGameEventToServer( "play_selected_sound", { pID: iPlayerID, unit_index: e.entityIndex, pissed: true})
	                    return false;
	                }
	                else
	                	GameEvents.SendCustomGameEventToServer( "play_selected_sound", { pID: iPlayerID, unit_index: e.entityIndex, pissed: false})
            	}
            	else
            	{
            		lastClickedEntity = e.entityIndex
            		GameEvents.SendCustomGameEventToServer( "play_selected_sound", { pID: iPlayerID, unit_index: e.entityIndex, pissed: false})
            		ResetPissed(e.entityIndex)
            	}
            		    
            }
            else
           		ResetPissed(0)     
        }
    }
    else
    	ResetPissed(0)
}

function ResetPissed(entityIndex) {
	//$.Msg("Set pissed counter")
    lastClickedEntity = entityIndex;
    clickedCounter = 0;
}

function DeselectBuildings() {
	var iPlayerID = Players.GetLocalPlayer();
	var selectedEntities = Players.GetSelectedEntities( iPlayerID );
	
	skip = true;
	var first = FirstNonBuildingEntityFromSelection(selectedEntities)
	GameUI.SelectUnit(first, false); // Overrides the selection group

	for (var unit of selectedEntities) {
		skip = true; // Makes it skip an update
		if (!IsCustomBuilding(unit) && unit != first){
			GameUI.SelectUnit(unit, true);
		}
	}
}

function FirstNonBuildingEntityFromSelection( entityList ){
	for (var i = 0; i < entityList.length; i++) {
		if (!IsCustomBuilding(entityList[i])){
			return entityList[i]
		}
	}
	return 0
}

function GetFirstUnitFromSelectionSkipUnit ( entityList, entIndex ) {
	for (var i = 0; i < entityList.length; i++) {
		if ((entityList[i]) != entIndex){
			return entityList[i]
		}
	}
	return 0
}

function SendSelectedEntities (params) {
	var iPlayerID = Players.GetLocalPlayer();
	var newSelectedEntities = Players.GetSelectedEntities( iPlayerID );
	GameEvents.SendCustomGameEventToServer( "update_selected_entities", { pID: iPlayerID, selected_entities: newSelectedEntities })
}

// Returns whether the selection group contains both buildings and non-building units
function IsMixedBuildingSelectionGroup ( entityList ) {
	var buildings = 0
	var nonBuildings = 0
	for (var i = 0; i < entityList.length; i++) {
		if (IsCustomBuilding(entityList[i])){
			buildings++
		}
		else {
			nonBuildings++
		}
	}
	//$.Msg( "Buildings: ",buildings, " NonBuildings: ", nonBuildings)
	return (buildings>0 && nonBuildings>0)
}

function IsCustomBuilding( entityIndex ){
	var ability_building = Entities.GetAbilityByName( entityIndex, "ability_building")
	var ability_tower = Entities.GetAbilityByName( entityIndex, "ability_tower")
	if (ability_building != -1){
		//$.Msg(entityIndex+" IsCustomBuilding - Ability Index: "+ ability_building)
		return true
	}
	else if (ability_tower != -1){
		//$.Msg(entityIndex+" IsCustomBuilding Tower - Ability Index: "+ ability_tower)
		return true
	}
	else
		return false
}

function IsCityCenter( entityIndex ){
	return (Entities.GetUnitLabel( entityIndex ) == "city_center")
}

function AddToSelection ( args ) {
	//$.Msg("Add To Selection")
	var entIndex = args.ent_index
	GameUI.SelectUnit(entIndex, true)
	OnUpdateSelectedUnit( args )
}

function NewSelection ( args ) {
	//$.Msg("New Selection")
	var entIndex = args.ent_index
	GameUI.SelectUnit(entIndex, false)
	OnUpdateSelectedUnit( args )
}

function RemoveFromSelection ( args ) {
	//$.Msg("Remove From Selection")
	var entIndex = args.ent_index

	var iPlayerID = Players.GetLocalPlayer();
	var selectedEntities = Players.GetSelectedEntities( iPlayerID );

	skip = true;
	GameUI.SelectUnit(GetFirstUnitFromSelectionSkipUnit(selectedEntities, entIndex), false); // Overrides the selection group

	for (var i = 0; i < selectedEntities.length; i++) {
		skip = true; // Makes it skip an update
		if ((selectedEntities[i]) != entIndex){
			GameUI.SelectUnit(selectedEntities[i], true);
		}
	}
	OnUpdateSelectedUnit( args )
}

(function () {
	GameEvents.Subscribe( "add_to_selection", AddToSelection );
	GameEvents.Subscribe( "remove_from_selection", RemoveFromSelection);
	GameEvents.Subscribe( "new_selection", NewSelection);
	GameEvents.Subscribe( "dota_player_update_selected_unit", OnUpdateSelectedUnit );
})();