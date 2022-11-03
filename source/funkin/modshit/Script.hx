package funkin.modshit;

import flixel.FlxBasic;
import flixel.util.FlxColor;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import lime.app.Application;
import lime.utils.Assets;
import openfl.display.BlendMode;
import sys.io.File;

using StringTools;

class HScript
{
	public var _path:String;
	public var script:String;

	public var parser:Parser = new Parser();
	public var program:Expr;
	public var interp:Interp = new Interp();

	public var subScripts:Array<HScript> = [];

	public var executedScript:Bool = false;

	public function new(path:String)
	{
		try
		{
			_path = path;
			script = File.getContent(Paths.hscript(path));

			parser.allowJSON = true;
			parser.allowTypes = true;
			parser.allowMetadata = true;
			interp.importBlocklist.push('Sys');

			setVariable("trace", function(a) { trace(a); });
			setVariable("state", flixel.FlxG.state);
			setVariable("Main", Main);
			setVariable("FlxAxes", flixel.util.FlxAxes);
			setVariable("FlxSprite", flixel.FlxSprite);
			setVariable("FlxG", flixel.FlxG);
			setVariable("Paths", Paths);
			setVariable("Std", Std);
			setVariable("add", function(obj:FlxBasic) {flixel.FlxG.state.add(obj);});
			setVariable("FlxColor", HScriptClasses.getFlxColorClass());
			setVariable("BlendMode", HScriptClasses.getBlendModeClass());
			setVariable("Json", {
				"parse": haxe.Json.parse,
				"stringify": haxe.Json.stringify
			});

			program = parser.parseString(script);

			interp.errorHandler = function(e)
			{
				// note to self (inky): make a logs system
				trace('$e');
				// if (!flixel.FlxG.keys.pressed.SHIFT)
				// {
				// 	var posInfo = interp.posInfos();

				// 	var lineNumber = Std.string(posInfo.lineNumber);
				// 	var methodName = posInfo.methodName;
				// 	var className = posInfo.className;

				// 	#if windows
				// 	Application.current.window.alert('Exception occured at line $lineNumber ${methodName == null ? "" : 'in $methodName'}\n\n${e}\n\nIf the message boxes blocks the engine, hold down SHIFT to bypass.',
				// 		'HScript error! - $path.hscript');
				// 	#else
				// 	//Main.print("error", 'Exception occured at line $lineNumber ${methodName == null ? "" : 'in $methodName'}\n\n${e}\n\nHX File: $path.hxs');
				// 	#end
				// }
			};
			interp.execute(program);
		}
		catch (e)
		{
			trace(e.message);
		}
	}

	public function create(?args)
	{
		executedScript = true;
		callFunction("create", args);
	}

	public function update(elapsed:Float)
	{
		if (executedScript)
			callFunction("update", [elapsed]);
	}
	public function stepHit(step:Int) {
		if (executedScript)
			callFunction("stepHit", [step]);
	}
	public function beatHit(beat:Int) {
		if (executedScript)
			callFunction("beatHit", [beat]);
	}

	public function callFunction(func:String, ?args:Array<Dynamic>)
	{
		if (!executedScript)
			return;

		if (interp.variables.exists(func))
		{
			var real_func = interp.variables.get(func);
			try
			{
				if (args == null)
					real_func();
				else
					Reflect.callMethod(null, real_func, args);
			}
			catch (e)
			{
				trace(_path + ".hscript:" + Std.string(interp.posInfos().lineNumber) + ": ERROR Caused in " + func + "(" + Std.string(args) + ") - Details: "
					+ e.details());
			}
		}

		for (subScript in subScripts)
			subScript.callFunction(func, args);
	}

	public function setVariable(variable:String, value:Dynamic)
		interp.variables.set(variable, value);

	public function getVariable(variable:String) :Dynamic
		return interp.variables.get(variable);
}

class HScriptClasses
{
	public static function getBlendModeClass()
	{
		return {
			"ADD": BlendMode.ADD,
			"ALPHA": BlendMode.ALPHA,
			"DARKEN": BlendMode.DARKEN,
			"DIFFERENCE": BlendMode.DIFFERENCE,
			"ERASE": BlendMode.ERASE,
			"HARDLIGHT": BlendMode.HARDLIGHT,
			"INVERT": BlendMode.INVERT,
			"LAYER": BlendMode.LAYER,
			"LIGHTEN": BlendMode.LIGHTEN,
			"MULTIPLY": BlendMode.MULTIPLY,
			"NORMAL": BlendMode.NORMAL,
			"OVERLAY": BlendMode.OVERLAY,
			"SCREEN": BlendMode.SCREEN,
			"SHADER": BlendMode.SHADER,
			"SUBTRACT": BlendMode.SUBTRACT
		}
	}

	public static function getFlxColorClass()
	{
		return {
			// color lore
			"BLACK": FlxColor.BLACK,
			"BLUE": FlxColor.BLUE,
			"BROWN": FlxColor.BROWN,
			"CYAN": FlxColor.CYAN,
			"GRAY": FlxColor.GRAY,
			"GREEN": FlxColor.GREEN,
			"LIME": FlxColor.LIME,
			"MAGENTA": FlxColor.MAGENTA,
			"ORANGE": FlxColor.ORANGE,
			"PINK": FlxColor.PINK,
			"PURPLE": FlxColor.PURPLE,
			"RED": FlxColor.RED,
			"TRANSPARENT": FlxColor.TRANSPARENT,
			"WHITE": FlxColor.WHITE,
			"YELLOW": FlxColor.YELLOW,

			// functions
			"add": FlxColor.add,
			"fromCMYK": FlxColor.fromCMYK,
			"fromHSB": FlxColor.fromHSB,
			"fromHSL": FlxColor.fromHSL,
			"fromInt": FlxColor.fromInt,
			"fromRGB": FlxColor.fromRGB,
			"fromRGBFloat": FlxColor.fromRGBFloat,
			"fromString": FlxColor.fromString,
			"interpolate": FlxColor.interpolate,
		};
	}
}