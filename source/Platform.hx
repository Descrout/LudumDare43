package;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxG;

/**
 * ...
 * @author Adil Basar
 */
class Platform extends FlxSprite
{

	private var player:Player;
	public function new(X:Int, Y:Int, vis:String, P:Player) 
	{
		super(X, Y);
		loadGraphic(AssetPaths.platform__png, false, 32, 32);
		if (vis == "False") visible = false;
		immovable = true;
		allowCollisions = FlxObject.UP;
		player = P;
	}
	
	override public function update(elapsed:Float):Void
	{
		if(overlaps(player)){
			if (FlxG.keys.pressed.S) allowCollisions = FlxObject.NONE;
			else allowCollisions = FlxObject.UP;
		}
		super.update(elapsed);
	}
	
}