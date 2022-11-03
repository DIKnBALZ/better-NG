package funkin;

import sys.FileSystem;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import haxe.Resource;
import flixel.text.FlxText;

class ModMenuState extends MusicBeatState {
    override public function create() {
        FlxTransitionableState.defaultTransIn = new TransitionData(TransitionType.TILES, FlxColor.BLACK, 0.35);
	    FlxTransitionableState.defaultTransOut = new TransitionData(TransitionType.TILES, FlxColor.BLACK, 0.35);

        var background:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("menuBG"));
        add(background);

        var uibackground:FlxSprite = new FlxSprite(0, 0).makeGraphic(1024, 576, FlxColor.BLACK);
        add(uibackground);

        var modNameText:FlxText = new FlxText(25, 25, 0, "Name", 80);
        modNameText.setFormat(Paths.font("funkin.otf"), 30, FlxColor.WHITE, CENTER, SHADOW, FlxColor.BLACK);
        modNameText.shadowOffset.x = 5;
        modNameText.shadowOffset.y = 5;
        add(modNameText);

        trace(CoolUtil.modList);
        for (i in FileSystem.readDirectory("assets/mods")) {
            var modJson = haxe.Json.parse(Paths.file('mods/$i/pack.json'));
            var modName:String = modJson.name;
            modNameText.text = modName;
        }

        super.create();
    }
}