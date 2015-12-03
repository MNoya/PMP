"use strict";
var tutorialSound;

function TutorialStart() {
    tutorialSound = Game.EmitSound("Tutorial.Start")
    GameEvents.SendCustomGameEventToServer( "tutorial_start", {} );
    $("#TutorialPanel").AddClass("FadeOut")
}

function TutorialEnd() {
    GameEvents.SendCustomGameEventToServer( "tutorial_end", {} );
}

function TutorialStopSound() {
    if (tutorialSound)
    {
        Game.StopSound(tutorialSound)
        Game.EmitSound("Tutorial.End")
    }
}

function Close () {
    $("#TutorialPanel").AddClass("FadeOut")
    $("#CloseButton").AddClass("FadeOut")
    GameEvents.SendCustomGameEventToServer( "tutorial_end", {} );
}

(function(){
    GameEvents.Subscribe( "tutorial_stop_sound", TutorialStopSound )
})()