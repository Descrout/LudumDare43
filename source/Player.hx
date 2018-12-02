package;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;

/**
 * ...
 * @author Adil Basar
 */
class Player extends FlxSprite
{

	
	public var speed:Int;

	private var sagBas:Bool;
	private var solBas:Bool;
	private var ustBas:Bool;
	
	private var jumpStop:Bool;
	
	private var canJump:Bool;

	private var mouseAng:Float;

	private var shootTimer:FlxTimer;

	private var bullets:FlxTypedGroup<Bullet>;
	
	public var gun:FlxSprite;

	
	public function new(playState:PlayState) 
	{
		super();
		
		loadGraphic(AssetPaths.player__png, true , 48,48);

		animation.add("idle", [0], 1, false);
		animation.add("goUp", [1], 1, false);
		animation.add("goDown", [2], 1, false);
		animation.add("walk", [3, 4, 5, 6], 12, true);
		
		speed = ForBahri.playerXAcc;
		
		setSize(20, 48);
		offset.set(14, 0);
		
		maxVelocity.set(ForBahri.playerMaxVelX, ForBahri.playerMaxVelY);
    	acceleration.y = ForBahri.playerGravity;
		drag.x = maxVelocity.x * speed;
		
		bullets = playState.bullets;

		shootTimer = new FlxTimer();
		
		jumpStop = false;
		
		gun = new FlxSprite();
		gun.loadGraphic(AssetPaths.gun__png, false, 28, 9);
		gun.origin.set(10, 5);

		
		FlxG.camera.follow(this,LOCKON,0.1);
	}
	
	public function die():Void
	{
		kill();
		FlxG.camera.shake(0.02, 0.2);
	}
	
	private function shoot():Void
	{
		shootTimer.start(ForBahri.playerFireRate);
		
		bullets.recycle().shoot(getMidpoint(_point), mouseAng);
		
		//FlxG.camera.shake(0.005, 0.05);
	}
	
	private function handleAnimation():Void
	{
    	if (canJump){
			animation.play("walk");
    		if (velocity.x >-10 && velocity.x < 10) animation.play("idle");
    	}else{
    		if (velocity.y < 0) animation.play("goUp");
			else animation.play("goDown");
    	}
    }
	
	private function handleInput():Void
	{
    	solBas=false;
    	sagBas=false;
    	ustBas=false;

    	if(FlxG.keys.pressed.A) solBas=true;
    	if(FlxG.keys.pressed.D) sagBas=true;
    	if(FlxG.keys.pressed.W) ustBas = true;
		if(FlxG.keys.justReleased.W && velocity.y<0) jumpStop = true;
    	if(FlxG.mouse.pressed && !shootTimer.active) shoot();
		
		//if(FlxG.keys.pressed.SPACE && velocity.y > 10) velocity.y *= 0.8;
			
    	if (ustBas && canJump) velocity.y = -400;
		
		if(solBas){
			acceleration.x = -maxVelocity.x * speed;
			flipX = true;	
		} 
		if(sagBas) {
			acceleration.x = maxVelocity.x * speed;
			flipX = false;
		}
    }
	
	private function gunHandle():Void
	{
		
		var mp:FlxPoint = FlxG.mouse.getPosition();
		mouseAng = getMidpoint(_point).angleBetween(mp);
		gun.x = this.x;
		gun.y = this.y + 30;
		gun.angle = mouseAng - 90;
		
		if (mp.x > this.x) gun.flipY = false;
		else gun.flipY = true;
	}
	
	override public function update(elapsed:Float):Void
	{
		
		canJump = isTouching(FlxObject.DOWN);
		
    	acceleration.x = 0;
		
		gunHandle();
		
		handleInput();
		
		handleAnimation();
		
		if (jumpStop){
			velocity.y *= 0.9;
			if (velocity.y > 0) jumpStop = false;
		}
    	
        super.update(elapsed);
    }
	
}