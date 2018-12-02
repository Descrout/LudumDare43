package;
import flixel.FlxSprite;
import flixel.FlxG;
/**
 * ...
 * @author Adil Basar
 */
class Bird extends FlxSprite
{
	private var player:Player;
	private var rX:Float;
	private var rY:Float;
	private var timer:Float;
	public function new(X:Int, Y:Int, P:Player) 
	{
		super(X, Y);
		player = P;
		loadGraphic(AssetPaths.bat__png, true, 38, 25);
		animation.add("fly", [0, 1], 6);
		animation.play("fly");
		
		getRandomPos();
	}
	
	private function getRandomPos():Void
	{
		rX = FlxG.random.int( -80, 80);
		rY = FlxG.random.int( -80, 80);
		timer = FlxG.random.float(1, 4);
	}
	
	override public function update(elapsed:Float):Void
	{
		timer -= elapsed;
		if (timer < 0) getRandomPos();
		
		velocity.x = player.x + rX - x;
		velocity.y = player.y + rY - y;
		super.update(elapsed);
	}
	
}