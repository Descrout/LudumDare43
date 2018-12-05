package;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.tile.FlxTilemap;
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
	private var changeTime:Float;
	private var timer:Float;
	private var direction:Int;
	private var damage:Float;
	private var tileMap:FlxTilemap;
	private var knockback:Int;
	public var rageAmount:Int;
	
	public function new(X:Int, Y:Int, P:Player, TileMap:FlxTilemap) 
	{
		super(X, Y);
		loadGraphic(AssetPaths.crab_walk__png, true, 32, 32);
		animation.add("idle",[0,1],3,true);
		animation.add("walk", [2, 3, 4, 5, 6, 7], 12, true);
		animation.add("up", [8]);
		animation.add("down",[9]);
		animation.play("idle");
		
		setSize(32, 16);
		offset.set(0, 16);
		
		brain = new FSM(idle);
		
		direction = 0;
		health = ForBahri.crabHP;
		rageAmount = ForBahri.crabRageAmount;
		speed = FlxG.random.int(5, 10);
		timer = 0;
		changeTime = FlxG.random.float(1, 4);
		jumpSpeed = FlxG.random.int(ForBahri.crabJumpMin, ForBahri.crabJumpMax);
		maxVelocity.set(FlxG.random.int(ForBahri.crabRunSpeedMin, ForBahri.crabRunSpeedMax),ForBahri.crabJumpMax);
		acceleration.y = ForBahri.crabGravity;
		damage = ForBahri.crabDamage;
		knockback = ForBahri.crabKnockback;
		drag.x = maxVelocity.x * speed;
		player = P;
		tileMap = TileMap;
	}

	public function idle():Void
	{
		if(timer>changeTime){
			if(direction == -1 || direction == 1){
				animation.play("idle");
				direction = 0;
			}else {
				if(FlxG.random.bool(50)){
					direction = 1;
					flipX = false;
				}else{
					direction = -1;
					flipX = true;
				} 
				animation.play("walk");
			}
			changeTime = FlxG.random.float(1, 4);
			timer=0;
		}

		if(isTouching(FlxObject.WALL) || tileMap.getTile(Std.int((x+32*direction) / 32),Std.int((y+32)/ 32))==0) {
			direction *= -1;
			flipX = !flipX;
			changeTime = FlxG.random.float(0.2, 1);
		}
		
		acceleration.x = maxVelocity.x * speed * direction;
		
		
		if(FlxMath.distanceBetween(player,this) < ForBahri.crabTriggerRange){
			if (tileMap.ray(getMidpoint(), player.getMidpoint())){
				animation.play("walk");
				timer = 0;
				brain.activeState = chase;
			}
		}
		
		if (velocity.y > 0) animation.play("down");
		
	}
	
	override public function kill():Void{
		player.rage += rageAmount;
		super.kill();
	}
	
	public function attack():Void
	{
		
		if(timer > 1){
			timer = 0;
			brain.activeState = chase;
			animation.play("walk");
		}else {
			if (velocity.y < -5 && overlaps(player)) player.getHurt(damage, this, knockback);
			if (velocity.y > 0) animation.play("down");
		}
	}
	
	public function chase():Void
	{
		if(timer > 2){
			animation.play("idle");
			direction = 0;
			timer = 0;
			brain.activeState = idle;
		}

		if(player.x > x){
			direction = 1;
			flipX=false;
		}else {
			direction = -1;
			flipX=true;
		}
		
		acceleration.x = maxVelocity.x * speed * direction;
		
		if(FlxMath.distanceToPoint(this, player.getMidpoint()) < 40){
			jump();
			velocity.x = direction * 250;
			brain.activeState = attack;

			timer = 0;
		}
		
		if (isTouching(FlxObject.RIGHT) || isTouching(FlxObject.LEFT)) jump();
		if (velocity.y > 0) animation.play("down");
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
		if(isTouching(FlxObject.DOWN)){
			animation.play("up");
			velocity.y = -jumpSpeed;
		}
	}
	
	override public function update(elapsed:Float):Void
	{
		acceleration.x = 0;	
		timer += elapsed;
		
		brain.update();

		super.update(elapsed);
	}
}