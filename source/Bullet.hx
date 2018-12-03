package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
/**
 * ...
 * @author Adil Basar
 */
class Bullet extends FlxSprite
{
	public var speed:Int;
	public var aim:Int;
	

	public function new() 
	{
		super();
		loadGraphic(AssetPaths.bullet__png,true,36,18);
		animation.add("shoot", [0, 1], 24, false);
		animation.add("poof", [2, 3, 4], 24, false);
		setSize(10, 9);
		origin.set(18, 9);
        offset.set(15,5);
		speed = ForBahri.playerBulletSpeed;
		health = ForBahri.playerBulletDamage;
		exists = false;
		aim = FlxG.random.int(-6, 6);
	}
	
	override public function update(elapsed:Float):Void
	{
		if(touching!=0)kill();
		if (!alive && animation.finished || !isOnScreen())exists = false;


		super.update(elapsed);
	}
	
	override public function kill():Void
	{
		if (!alive) return;
	
		velocity.set(0, 0);
		animation.play("poof");
		alive = false;
		solid = false;
	}
	
	public function shoot(Location:FlxPoint, Angle:Float):Void 
	{
		super.reset(Location.x - width / 2, Location.y - height / 2 + 8 + aim);
		_point.set(0, -speed);
		angle=Angle-90;
		_point.rotate(FlxPoint.weak(0, 0), Angle);
		velocity.x = _point.x;
		velocity.y = _point.y;
		solid = true;
		animation.play("shoot");
		FlxG.camera.shake(ForBahri.cameraShakeIntensity, ForBahri.cameraShakeDuration);
	}
}