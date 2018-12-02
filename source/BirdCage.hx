package;
import flixel.FlxSprite;
import flixel.FlxG;
/**
 * ...
 * @author Adil Basar
 */
class BirdCage extends FlxSprite
{

	private var playState:PlayState;

	public function new(X:Int, Y:Int, P:PlayState) 
	{
		super(X, Y);
		loadGraphic(AssetPaths.batCage__png, false, 32, 48);
		playState = P;
	}
	
	override public function update(elapsed:Float):Void
	{
		if (overlaps(playState.player))
		{
			if(FlxG.keys.pressed.E){
				playState.birds.add(new Bird(Std.int(x), Std.int(y), playState.player));
				kill();
			}
		}
	}
	
	
}