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
	private var attackRange:Int;
	
	private var touchingDown:Bool;
	private var touchingWall:Bool;
	
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
		
		attackRange = FlxG.random.int(ForBahri.crabAttackRangeMin, ForBahri.crabAttackRangeMax);
		direction = 0;
		health = ForBahri.crabHP;
		rageAmount = ForBahri.crabRageAmount;
		speed = FlxG.random.int(ForBahri.crabRunSpeedMin, ForBahri.crabRunSpeedMax);
		timer = 0;
		changeTime = FlxG.random.float(1, 4);
		jumpSpeed = FlxG.random.int(ForBahri.crabJumpMin, ForBahri.crabJumpMax);
		maxVelocity.set(800, ForBahri.crabJumpMax);
		acceleration.y = ForBahri.crabGravity;
		damage = ForBahri.crabDamage;
		knockback = ForBahri.crabKnockback;
		drag.x = speed * 3;
		player = P;
		tileMap = TileMap;
	}

	public function move():Void
	{
		acceleration.x = speed  * direction;
		if (touchingDown){
			if(velocity.x > speed) velocity.x = speed;
			else if (velocity.x < -speed) velocity.x = -speed;
		}
	}
	
	public function whichSide():Void
	{
		if(player.x+player.width/2 > x+width/2){
			direction = 1;
			flipX=false;
		}else {
			direction = -1;
			flipX=true;
		}
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
			timer = 0;
			return;
		}
		
		
		if(touchingDown && (touchingWall || tileMap.getTile(Std.int((x+16 + (16*direction)) / 32),Std.int((y+32)/ 32))==0)){
			direction *= -1;
			velocity.x *= -0.5;
			flipX = !flipX;
			changeTime = FlxG.random.float(0.2, 1);
		}
		
		move();
		
		if(inRange(ForBahri.crabTriggerRange)){
			if (tileMap.ray(getMidpoint(), player.getMidpoint())){
				timer = 0;
				brain.activeState = chase;
			}
		}

	}
	
	public function inRange(range:Int):Bool
	{
		return (this.y + this.height > player.y - 40 && this.y < player.y + player.height + 40 &&
		 Math.abs(this.x - player.x) < range);
	}
	
	override public function kill():Void{
		player.rage += rageAmount;
		super.kill();
	}
	
	public function attack():Void
	{
		
		if(touchingDown){
			timer = 0;
			brain.activeState = chase;
			return;
		}
		
		
		if (touchingWall){
			direction *= -1;
			flipX = !flipX;
			velocity.x *= -1;
		} 
		if (overlaps(player)) player.getHurt(damage, this, knockback);
	}
	
	public function chase():Void
	{
		if(timer > 2){
			direction = 0;
			timer = 0;
			brain.activeState = idle;
			return;
		}

		if(inRange(attackRange)){
			brain.activeState = getReadyForAttack;
			timer = 0;
			return;
		}

		whichSide();
		
		move();

		if (touchingWall) jump();
	}
	
	public function getReadyForAttack(){
		direction = 0;
		flipX = !(player.x + player.width / 2 > x + width / 2);
		if(timer>0.6){
			jump();
			whichSide();
			brain.activeState = attack;
			velocity.x = direction * attackRange * 4 + 50;
			timer = 0;
		}
	}
	
	override public function hurt(dmg:Float):Void
	{
		FlxSpriteUtil.flicker(this, 0.2, 0.02, true);
		if(brain.activeState == idle){
			timer = 0;
			brain.activeState = chase;
		}
			

		if (brain.activeState == chase)
			timer = 0;
		super.hurt(dmg);		
	}
	
	private function jump():Void
	{
		if(touchingDown)
			velocity.y = -jumpSpeed;
	}
	
	private function handleAnim():Void
	{
		if(touchingDown){
			if (direction == 0) animation.play("idle");
			else animation.play("walk");
		}else{
			if (velocity.y < 0) animation.play("up");
			else animation.play("down");
		}
	}
	
	override public function update(elapsed:Float):Void
	{
		touchingDown = isTouching(FlxObject.DOWN);
		touchingWall = isTouching(FlxObject.WALL);
		
		acceleration.x = 0;	
		
		timer += elapsed;
		
		brain.update();
		
		handleAnim();
		
		trace(velocity.x);
		super.update(elapsed);
	}
}