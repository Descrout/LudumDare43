package;
import flixel.FlxSprite;

/**
 * ...
 * @author Adil Basar
 */
class Door extends FlxSprite
{
	private var player:Player;

	public function new(P:Player) 
	{
		super();
		loadGraphic(AssetPaths.door__png, false, 32, 48);
		player = P;
	}
	
	override public function update(elapsed:Float):Void
	{
		if (overlaps(player))
		{
			
		}
	}
	
}