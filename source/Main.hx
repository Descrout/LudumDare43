package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var levels:Array<String>;
	
	public static  var  currentLevel:Int;
	
	public static var maxLevel:Int = 1;
	
	public static var timePassed:Float = 0;
	
	public function new()
	{
		super();
		
		currentLevel = 0;
		
		levels = [];
		for(i in 0...maxLevel){
			levels.push("assets/data/level" + (i + 1) + ".oel");
		}
		
		addChild(new FlxGame(0, 0, PlayState, 1, 60, 60, true, false));
	}
}