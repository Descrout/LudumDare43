package;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author Adil Basar
 */
class Crab extends FlxSprite
{
	private var brain:FSM;
	private var player:Player;
	private var speed:Int;
	private var jumpSpeed:Int;
	private var changeTime:Int;
	private var timer:Float;
	private var direction:Int;
	private var chancer:Int;
	
	public function new(X:Int, Y:Int, P:Player) 
	{
		super(X, Y);
		loadGraphic(AssetPaths.crab__png, true, 32, 32);
		animation.add("idle",[0]);
		animation.add("walk",[1,2,3,4],12,true);
		animation.play("idle");
		
		brain = new FSM(idle);
		
		direction = 0;
		chancer = 50;
		health = ForBahri.crabHP;
		speed = FlxG.random.int(5, 10);
		timer = 0;
		changeTime = FlxG.random.int(1, 3);
		jumpSpeed = FlxG.random.int(ForBahri.crabJumpMin, ForBahri.crabJumpMax);
		maxVelocity.set(FlxG.random.int(ForBahri.crabRunSpeedMin, ForBahri.crabRunSpeedMax),ForBahri.crabJumpMax);
		acceleration.y = ForBahri.crabGravity;
		drag.x = maxVelocity.x * speed;
		player = P;
	}

	public function idle():Void
	{
		if(timer>changeTime){
			if(direction == -1 || direction == 1){
				animation.play("idle");
				direction = 0;
			}else {
				if(FlxG.random.bool(chancer)){
					direction = 1;
					flipX = false;
					chancer-=10;
				}else{
					direction = -1;
					flipX = true;
					chancer+=10;
				} 
				animation.play("walk");
			}
			timer=0;
		}

		acceleration.x = maxVelocity.x * speed * direction;
		

		if(Math.abs(player.y - y) < 20){
			if ((Math.abs(player.x - x) < 200) ){
				animation.play("walk");
				timer = 0;
				brain.activeState = chase;
			}
		}
	}
	
	public function chase():Void
	{
		if(timer > 3){
			animation.play("idle");
			direction = 0;
			timer = 0;
			brain.activeState = idle;
		}

		if(player.x > x){
			acceleration.x = maxVelocity.x * speed;
			flipX=false;
		}else {
			acceleration.x = -maxVelocity.x * speed;
			flipX=true;
		}

	}
	
	override public function hurt(dmg:Float):Void
	{
		FlxSpriteUtil.flicker(this, 0.2, 0.02, true);

		brain.activeState = chase;
		animation.play("walk");
		timer = 0;

		super.hurt(dmg);		
	}
	
	private function jump():Void
	{
		if(isTouching(FlxObject.DOWN))velocity.y = -jumpSpeed;
	}
	
	override public function update(elapsed:Float):Void
	{
		acceleration.x = 0;	
		timer += elapsed;
		
		brain.update();
		
		if (isTouching(FlxObject.RIGHT)) jump();
		if (isTouching(FlxObject.LEFT)) jump();
		
		super.update(elapsed);
	}
}