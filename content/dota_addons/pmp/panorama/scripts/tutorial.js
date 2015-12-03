"use strict";
var tutorialSound = 0;
var byeSound = 0;
var active = false;

function TutorialStart() {
    if (!active) //Activate
    {
        tutorialSound = Game.EmitSound("Tutorial.Start")
        GameEvents.SendCustomGameEventToServer( "tutorial_start", {} );
        ToggleOn()
    }
    else //Cancel
    {
        ToggleOff()
        GameEvents.SendCustomGameEventToServer( "tutorial_end", {} );
    }
}

function ToggleOn() {
    active = true
    $("#TutorialPanel").AddClass("Cancel")
    $("#TutorialText").text = "CANCEL"
    if (byeSound) Game.StopSound(byeSound)
}

function ToggleOff() {
    active = false
    $("#TutorialPanel").RemoveClass("Cancel")
    $("#TutorialText").text = "TUTORIAL"
}

function TutorialStop() {
    if (tutorialSound)
    {
        Game.StopSound(tutorialSound)
        ToggleOff()
        byeSound = Game.EmitSound("Tutorial.End")
    }
}

function Close () {
    if (tutorialSound) Game.StopSound(tutorialSound)
    $("#TutorialPanel").AddClass("FadeOut")
    $("#CloseButton").AddClass("FadeOut")
}

(function(){
    GameEvents.Subscribe( "tutorial_stop_sound", TutorialStop )
})()