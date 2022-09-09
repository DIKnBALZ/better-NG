package funkin;

#if desktop
	import funkin.Discord.DiscordClient;
#end
import funkin.ui.PreferencesMenu;
import funkin.shaderslmfao.BuildingShaders;
import funkin.shaderslmfao.ColorSwap;

import openfl.display.Sprite;
import openfl.net.NetStream;
import openfl.media.Video;
#if desktop
	import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import openfl.Lib;

using StringTools;
class TitleState extends MusicBeatState {
	public static var initialized:Bool = false;
	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var curWacky:Array<String> = [];
	var wackyImage:FlxSprite;
	var swagShader:ColorSwap;
	var alphaShader:BuildingShaders;

	#if web
		var video:Video;
		var netStream:NetStream;
		var overlay:Sprite;
	#end

	override public function create():Void {
		#if polymod
			polymod.Polymod.init({modRoot: "mods", dirs: ['introMod'], framework: OPENFL});
		#end

		FlxG.game.focusLostFramerate = 60;
		swagShader = new ColorSwap();
		alphaShader = new BuildingShaders();
		FlxG.sound.muteKeys = [ZERO];
		curWacky = FlxG.random.getObject(getIntroTextShit());
		super.create();
		FlxG.save.bind('funkin', 'ninjamuffin99');
		PreferencesMenu.initPrefs();
		PlayerSettings.init();
		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null) {
			if (StoryMenuState.weekUnlocked.length < 4) StoryMenuState.weekUnlocked.insert(0, true);
			if (!StoryMenuState.weekUnlocked[0]) StoryMenuState.weekUnlocked[0] = true;
		}

		if (FlxG.save.data.seenVideo != null) VideoState.seenVideo = FlxG.save.data.seenVideo;

		#if FREEPLAY
			FlxG.switchState(new FreeplayState());
		#elseif CHARTING
			FlxG.switchState(new ChartingState());
		#else
			new FlxTimer().start(1, function(tmr:FlxTimer) {
				startIntro();
			});
		#end

		#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	function startIntro() {
		if (!initialized) {
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1), {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}
		Conductor.changeBPM(102);
		persistentUpdate = true;

		// var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// add(bg);


		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		gfDance.shader = swagShader.shader;
		add(gfDance);
		
		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		logoBl.shader = swagShader.shader;
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();
		credTextShit.visible = false;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});
		FlxG.mouse.visible = false;
		if (initialized) skipIntro();
		else initialized = true;
		if (FlxG.sound.music != null) {
			FlxG.sound.music.onComplete = function() {
				FlxG.switchState(new VideoState());
			}
		}
	}

	function getIntroTextShit():Array<Array<String>> {
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];
		for (i in firstArray) swagGoodArray.push(i.split('--'));
		return swagGoodArray;
	}

	var transitioning:Bool = false;
	var isRainbow:Bool = false;
	override function update(elapsed:Float) {
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;
		if (FlxG.keys.justPressed.EIGHT) FlxG.switchState(new CutsceneAnimTestState());
		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;
		if (FlxG.keys.justPressed.F) FlxG.fullscreen = !FlxG.fullscreen;
		if (FlxG.keys.justPressed.FIVE) FlxG.switchState(new CutsceneAnimTestState());

		#if mobile
			for (touch in FlxG.touches.list) {
				if (touch.justPressed) pressedEnter = true;
			}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null) {
			if (gamepad.justPressed.START) pressedEnter = true;
			#if switch if (gamepad.justPressed.B) pressedEnter = true; #end
		}

		if (pressedEnter && !transitioning && skippedIntro) {
			if (FlxG.sound.music != null) FlxG.sound.music.onComplete = null;
			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
			titleText.animation.play('press');
			transitioning = true;
			FlxG.switchState(new MainMenuState());
		}

		if (pressedEnter && !skippedIntro && initialized) skipIntro();
		if (controls.UI_LEFT) {
			swagShader.update(elapsed * 0.5);
			FlxG.camera.shake(0.025, 0.01);
		} if (controls.UI_RIGHT) {
			swagShader.update(-elapsed * 0.5);
			FlxG.camera.shake(0.025, 0.01);
		}
		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>) {
		for (i in 0...textArray.length) {
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String) {
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText() {
		while (textGroup.members.length > 0) {
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit() {
		super.beatHit();
		logoBl.animation.play('bump');
		danceLeft = !danceLeft;
		if (danceLeft) gfDance.animation.play('danceRight');
		else gfDance.animation.play('danceLeft');
		
		switch (curBeat) {
			case 1:		createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			case 3:		addMoreText('present');
			case 4:		deleteCoolText();
			case 5:		createCoolText(['in association', 'with']);
			case 7:		addMoreText('inky and wizard');
			case 8:		deleteCoolText();
			case 9:		createCoolText([curWacky[0]]);
			case 11:	addMoreText(curWacky[1]);
			case 12:	deleteCoolText();
			case 13:	addMoreText('friday night funkin');
			case 14:	addMoreText('better engine');
			case 15: 	addMoreText('newgrounds edition');
			case 16:	skipIntro();
		}
	}

	var skippedIntro:Bool = false;
	function skipIntro():Void {
		if (!skippedIntro) {
			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}