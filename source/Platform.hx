package;
import flixel.FlxSprite;
import flixel.FlxObject;

/**
 * ...
 * @author Adil Basar
 */
class Platform extends FlxSprite
{

	public function new(X:Int, Y:Int, vis:String) 
	{
		super(X, Y);
		loadGraphic(AssetPaths.platform__png, false, 32, 32);
		if (vis == "False") visible = false;
		immovable = true;
		allowCollisions = FlxObject.UP;
	}
	
}