package;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;
import flixel.tile.FlxTilemap;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
/**
 * ...
 * @author Adil Basar
 */
class Rocky extends Enemy
{
	private var startX:Int;
	private var startY:Int;
	
	private var xToGo:Int;
	private var yToGo:Int;

	private var myOffset:Int;
	private var randomMove:Float;
	private var gibs:FlxEmitter;
	private var tileMap:FlxTilemap;
	
	private var player:Player;
	
	public function new(X:Int, Y:Int, P:Player, TileMap:FlxTilemap, Gibs:FlxEmitter) 
	{
		super(X, Y);
		
		brain = new FSM(idle);
		
		startX = X;
		startY = Y;
		player = P;
		tileMap = TileMap;
		gibs = Gibs;
		
		loadGraphic(AssetPaths.rocky__png, false, 32, 32);
	
		
		myOffset = ForBahri.rockyMoveOffset;
		health = ForBahri.rockyHP;
		rageAmount = ForBahri.rockyRage;
		speed = ForBahri.rockyIdleSpeed;
		knockbackRes = ForBahri.rockyKnockbackResistance;
		
		drag.set(speed * 3, speed * 3);
		angle = -40;
		randomMove = FlxG.random.float(2, 3);		
		getRandomPos();
	}
	
	private function idle():Void
	{
		if(timer<=0){
			getRandomPos();
		}
		goToPos();
		if(FlxMath.distanceBetween(this, player) < ForBahri.rockyTriggerRange){
			if (tileMap.ray(getMidpoint(), player.getMidpoint())){
				brain.activeState = chase;
			}
		}
	}
	
	private function getReadyForAttack():Void
	{
		if(timer<0){
			brain.activeState = attack;
			timer = 2;
			
			/*
			var Angle:Float = getMidpoint().angleBetween(player.getMidpoint());
			_point.set(0, -800);
			_point.rotate(FlxPoint.weak(0, 0), Angle);
			velocity.x = _point.x;
			velocity.y = _point.y;*/
			

		}
		
	}
	
	private function attack():Void
	{
		if(timer>0.5){
			acceleration.x += ((player.x > x) ? 1 : -1) * speed *2;
			acceleration.y += ((player.y > y) ? 1 : -1) * speed*2;
		}else if (timer < 0) brain.activeState = chase;
	}
	
	private function chase():Void
	{
		acceleration.x += ((player.x > x) ? 1 : -1) * speed;
		acceleration.y += ((player.y > y) ? 1 : -1) * speed;
		
		if(FlxMath.distanceBetween(this, player) < ForBahri.rockyTriggerRange){
			brain.activeState = getReadyForAttack;
			timer = 1;
		}
	}
	
	private function getRandomPos():Void
	{
		xToGo = FlxG.random.int(startX-myOffset, startX+myOffset);
		yToGo = FlxG.random.int(startY-myOffset, startY+myOffset);
		timer = FlxG.random.float(1, 4);
	}
	
	
	private function goToPos():Void
	{
		velocity.x = xToGo - x;
		velocity.y = yToGo - y;
	}
	
	override public function kill():Void{
		player.rage += rageAmount;
		//FlxG.camera.shake(0.007, 0.25);
		//FlxG.camera.flash(0xffd8eba2, 0.2, turnOffSlowMo);
		//FlxG.timeScale = 0.35;
		gibs.focusOn(this);
		gibs.velocity.set(hitObj.velocity.x/5-100, hitObj.velocity.y/5-100, hitObj.velocity.x/5+100, hitObj.velocity.y/5+100);
		gibs.start(true, 0, 12);
		super.kill();
	}
	
	override public function hurt(dmg:Float):Void
	{
		FlxSpriteUtil.flicker(this, 0.4, 0.02, true);
		velocity.x  += hitObj.velocity.x * knockbackRes;
		velocity.y  += hitObj.velocity.y * knockbackRes;
		super.hurt(dmg);
	}
	
	override public function update(elapsed:Float):Void
	{
		timer -= elapsed;
		
		angle += (Math.sin(Main.timePassed*randomMove) * 2); 
		
		brain.update();
		super.update(elapsed);
		acceleration.set(0, 0);
	}
}