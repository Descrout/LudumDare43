package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var levels:Array<String>;
	
	public static  var  currentLevel:Int;
	
	public static var maxLevel:Int = 1;
	
	public function new()
	{
		super();
		
		currentLevel = 0;
		
		levels = [];
		for(i in 0...maxLevel){
			levels.push("assets/data/level" + (i + 1) + ".oel");
		}
		
		addChild(new FlxGame(640, 480, PlayState, 1, 60, 60, true, false));
	}
}