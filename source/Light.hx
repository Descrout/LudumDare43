package;
import flixel.FlxSprite;
import flixel.FlxG;
/**
 * ...
 * @author Adil Basar
 */
class Light extends FlxSprite
{
	private var player:Player;
	private var rX:Float;
	private var rY:Float;
	private var timer:Float;
	public function new(P:Player) 
	{
		super(P.x, P.y);
		player = P;
		loadGraphic(AssetPaths.light__png, false, 32, 32);

		getRandomPos();
	}
	
	private function getRandomPos():Void
	{
		rX = FlxG.random.int( -55, 55);
		rY = FlxG.random.int( -55, 55);
		timer = FlxG.random.float(1, 4);
	}
	
	override public function update(elapsed:Float):Void
	{
		timer -= elapsed;
		if (timer < 0) getRandomPos();
		
		velocity.x = player.x + rX - x;
		velocity.y = player.y + rY - y;
		angle += 1;
		//if (angle > 360) angle = 0;
		super.update(elapsed);
	}
	
}