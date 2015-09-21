var SettingListener;
var IsHost = false;
var panels = [$("#TeamRow")];
var settings = ["TeamRow"];
var m_MenuMusic;
 
(function()
{
    CheckForHostPrivileges();
       
    /*$.Schedule(7, function() {
        m_MenuMusic = Game.EmitSound("");
        IsGameStarted();
    });*/

    // Set defaults
    SetSetting(settings[0], 2);

})();

function CheckForHostPrivileges()
{
    var playerInfo = Game.GetLocalPlayerInfo();
    if ( !playerInfo )
        return;

    // Set the "player_has_host_privileges" class on the panel, this can be used 
    // to have some sub-panels on display or be enabled for the host player.
    $.GetContextPanel().SetHasClass( "player_has_host_privileges", playerInfo.player_has_host_privileges );
}
 
function SetSetting(setting, choice)
{
    $.Msg("Choice ",choice)
    // Only hosts can change settings
    if(!IsHost){return;}
    GameEvents.SendCustomGameEventToServer( "SetSetting", {setting: setting, value: choice});
    ChangeSetting($("#" + setting), choice);
}
 
function ChangeSetting(panel, choice)
{
    //Game.EmitSound("");
    for (var i = 1; i <= panel.GetChildCount(); i++)
    {
        var child = panel.GetChild(i - 1);
        if(i == choice)
        {
            child.AddClass("SettingBoxSelected");
        }
        else if(child.BHasClass("SettingBoxSelected"))
        {
            child.RemoveClass("SettingBoxSelected");
        }
    };
}