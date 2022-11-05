package funkin;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.ui.FlxButton;
import openfl.net.FileReference;

class AnimationDebug extends FlxState {
	var _file:FileReference;
	var bf:Boyfriend;
	var dad:Character;
	var char:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;
	var camHUD:FlxCamera;
	public function new(daAnim:String = 'spooky') {
		super();
		this.daAnim = daAnim;
	}

	override function create() {
		FlxG.sound.music.stop();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);
		var gridBG:FlxSprite = FlxGridOverlay.create(5, 5);
		gridBG.scrollFactor.set(0.5, 0.5);
		gridBG.scale.set(5, 5);
		add(gridBG);
		if (daAnim == 'bf') isDad = false;
		if (isDad) {
			dad = new Character(0, 0, daAnim);
			dad.screenCenter();
			dad.debugMode = true;
			add(dad);
			char = dad;
			dad.flipX = false;
		} else {
			bf = new Boyfriend(0, 0);
			bf.screenCenter();
			bf.debugMode = true;
			add(bf);
			char = bf;
			bf.flipX = false;
		}

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);
		dumbTexts.cameras = [camHUD];

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		add(textAnim);
		textAnim.setFormat(Paths.font("funkin.otf"), 40, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		textAnim.borderSize = 2.5;
		textAnim.cameras = [camHUD];

		genBoyOffsets();
		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);
		FlxG.camera.follow(camFollow);

		// im gonna do this later
		// var saveButton:FlxButton = new FlxButton(textAnim.x, textAnim.y + 40, "Save", function()
		// {
		// 	saveOffsets();
		// });

		super.create();
	}

	function genBoyOffsets(pushList:Bool = true):Void {
		var daLoop:Int = 0;
		for (anim => offsets in char.animOffsets) {
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.setFormat(Paths.font("funkin.otf"), 30, FlxColor.BLUE, CENTER, OUTLINE, FlxColor.BLACK);
			text.borderSize = 2.5;
			text.borderQuality = 1;
			text.scrollFactor.set();
			text.cameras = [camHUD];
			dumbTexts.add(text);

			if (pushList) animList.push(anim);
			daLoop++;
		}
	}

	function updateTexts():Void {
		dumbTexts.forEach(function(text:FlxText) {
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	override function update(elapsed:Float) {
		textAnim.text = char.animation.curAnim.name;
		if (FlxG.keys.justPressed.E) FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q) FlxG.camera.zoom -= 0.25;

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L) {
			if (FlxG.keys.pressed.I) camFollow.velocity.y = -150 / FlxG.camera.zoom;
			else if (FlxG.keys.pressed.K) camFollow.velocity.y = 150 / FlxG.camera.zoom;
			else camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J) camFollow.velocity.x = -150 / FlxG.camera.zoom;
			else if (FlxG.keys.pressed.L) camFollow.velocity.x = 150 / FlxG.camera.zoom;
			else camFollow.velocity.x = 0;
		}
		else camFollow.velocity.set();
		if (FlxG.keys.justPressed.W) curAnim -= 1;
		if (FlxG.keys.justPressed.S) curAnim += 1;
		if (curAnim < 0) curAnim = animList.length - 1;
		if (curAnim >= animList.length) curAnim = 0;
		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE) {
			char.playAnim(animList[curAnim]);
			updateTexts();
			genBoyOffsets(false);
		}

		if (FlxG.keys.justPressed.ESCAPE) FlxG.switchState(new PlayState());

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);
		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift) multiplier = 10;
		if (upP || rightP || downP || leftP) {
			updateTexts();
			if (upP) char.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
			if (downP) char.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
			if (leftP) char.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
			if (rightP) char.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;
			updateTexts();
			genBoyOffsets(false);
			char.playAnim(animList[curAnim]);
		}
		super.update(elapsed);
	}
}