package;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;
/**
 * ...
 * @author Adil Basar
 */
class Enemy extends FlxSprite
{
	private var brain:FSM;
	private var rageAmount:Int;
	private var timer:Float;
	private var damage:Float;
	private var knockbackRes:Float;
	private var hitObj:FlxObject;
	private var speed:Int;
	
	public function new(X:Int, Y:Int) 
	{
		super(X, Y);
	}
	
	public function getHit(bullet:FlxObject):Void
	{
		hitObj = bullet;
		
		hurt(bullet.health);
	}
	
}