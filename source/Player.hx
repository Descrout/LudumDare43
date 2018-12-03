package;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.ui.FlxBar;
import flixel.util.FlxSpriteUtil;


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
	
	public var onStairs:Bool;
	public var onStairsCol:Bool;

	private var mouseAng:Float;

	private var shootTimer:FlxTimer;

	private var bullets:FlxTypedGroup<Bullet>;
	
	public var gun:FlxSprite;

	private var hpBar:FlxBar;
	
	private var hasSmg:Bool;
	
	public function new(playState:PlayState) 
	{
		super();
		
		loadGraphic(AssetPaths.player__png, true , 48,48);

		animation.add("idle", [0], 1, false);
		animation.add("goUp", [1], 1, false);
		animation.add("goDown", [2], 1, false);
		animation.add("walk", [3, 4, 5, 6], 12, true);
		
		acceleration.y = ForBahri.playerGravity;
		health = ForBahri.playerHP;
		speed = ForBahri.playerXAcc;
		
		setSize(20, 48);
		offset.set(14, 0);
		
		maxVelocity.set(ForBahri.playerMaxVelX, ForBahri.playerMaxVelY);
    	
		drag.x = maxVelocity.x * speed;
		
		bullets = playState.bullets;

		shootTimer = new FlxTimer();
		
		hpBar = new FlxBar(0, 0, LEFT_TO_RIGHT, 50, 10, this, "health", 0, 100, true);
		hpBar.trackParent(-12, -10);
		playState.add(hpBar);
		jumpStop = false;
		onStairs = false;
		onStairsCol = false;
		gun = new FlxSprite();
		gun.loadGraphic(AssetPaths.gun__png, false, 28, 9);
		gun.origin.set(10, 5);

		
		FlxG.camera.follow(this, LOCKON, 0.1);
		
		hasSmg = true;
	}
	
	public function getHurt(dmg:Float, obj:FlxObject, knockback:Int):Void
	{
		if (FlxSpriteUtil.isFlickering(this)) return;
		onStairs = false;
		acceleration.y = ForBahri.playerGravity;
		FlxSpriteUtil.flicker(this, 0.5, 0.02, true);
		velocity.x += knockback * ((obj.x < x) ? 1 : -1);
		velocity.y -= knockback;
		hurt(dmg);		
	}
	
	private function shoot():Void
	{
		if (hasSmg) shootTimer.start(ForBahri.playerSmgFireRate);
		else shootTimer.start(ForBahri.playerPistolFireRate);
		
		bullets.recycle().shoot(getMidpoint(_point), mouseAng);
		
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

		if (FlxG.keys.justPressed.Z) hasSmg = !hasSmg;
		
    	if(FlxG.keys.pressed.A && !onStairs) solBas=true;
    	if(FlxG.keys.pressed.D && !onStairs) sagBas=true;
    	if(FlxG.keys.pressed.SPACE) ustBas = true;
		if(FlxG.keys.justReleased.SPACE && velocity.y<0) jumpStop = true;
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
	
	private function stairHandle():Void
	{
		if (onStairs) {
			
			velocity.y = 0;
			if (FlxG.keys.pressed.W) velocity.y = -ForBahri.playerStairSpeed;
			if (FlxG.keys.pressed.S){
				velocity.y = ForBahri.playerStairSpeed;
				if(isTouching(FlxObject.DOWN)) {
					onStairs = false;
					acceleration.y = ForBahri.playerGravity;
				}
			}
			if (FlxG.keys.justPressed.SPACE || !onStairsCol) {
				onStairs = false;
				canJump = true;
				acceleration.y = ForBahri.playerGravity;
			}
		}
		onStairsCol = false;
	}
	
	override public function update(elapsed:Float):Void
	{
		canJump = isTouching(FlxObject.DOWN);
    	acceleration.x = 0;
		
		stairHandle();
		
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