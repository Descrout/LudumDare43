package;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.ui.FlxBar;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;

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
	
	public var rifle:FlxSprite;
	public var pistol:FlxSprite;
	public var head:FlxSprite;

	private var hpBar:FlxBar;
	private var rageBar:FlxBar;
	
	private var hasSmg:Bool;
	
	public var rage:Int;
	
	public function new(playState:PlayState) 
	{
		super();
		
		loadGraphic(AssetPaths.player_body_sprites__png, true , 34,34);

		animation.add("idle", [14], 1, false);
		animation.add("goUp", [12], 1, false);
		animation.add("goDown", [13], 1, false);
		animation.add("walk", [0,1,2,3,4,5,6,7,8,9,10,11], 12, true);
		
		acceleration.y = ForBahri.playerGravity;
		health = ForBahri.playerHP;
		speed = ForBahri.playerXAcc;
		
		rage = 0;
		
		setSize(20, 48);
		offset.set(5, -14);
		//offset.set(20, 16);
		
		maxVelocity.set(ForBahri.playerMaxVelX, ForBahri.playerMaxVelY);
    	
		drag.x = maxVelocity.x * speed;
		
		bullets = playState.bullets;

		shootTimer = new FlxTimer();
		
		hpBar = new FlxBar(0, 0, LEFT_TO_RIGHT, 50, 10, this, "health", 0, 100, true);
		hpBar.trackParent( -12, -20);
		hpBar.createFilledBar(FlxColor.BLACK, FlxColor.GREEN, true);
		playState.add(hpBar);
		
		rageBar = new FlxBar(0, 0, LEFT_TO_RIGHT, 50, 10, this, "rage", 0, 50, true);
		rageBar.trackParent( -12, -40);
		rageBar.createFilledBar(FlxColor.BLACK, FlxColor.YELLOW, true);
		playState.add(rageBar);
		
		jumpStop = false;
		onStairs = false;
		onStairsCol = false;
		rifle = new FlxSprite();
		rifle.loadGraphic(AssetPaths.rifle__png, false, 37, 18);
		rifle.origin.set(10, 9);

		
		pistol = new FlxSprite();
		pistol.loadGraphic(AssetPaths.pistol__png, false, 27, 16);
		pistol.origin.set(10, 8);
		pistol.visible = false;
		
		head = new FlxSprite();
		head.loadGraphic(AssetPaths.player_head_sprites__png, true, 34, 34);
		head.origin.y = 30;
		head.animation.add("idle", [2], 1, false);
		head.animation.add("down", [1], 1, false);
		head.animation.add("up", [0], 1, false);
		head.animation.play("idle");
		
		FlxG.camera.follow(this, LOCKON, 0.1);
		
		hasSmg = true;
	}
	
	public function getHurt(dmg:Float, obj:FlxObject, knockback:Int):Void
	{
		if (FlxSpriteUtil.isFlickering(this)) return;
		onStairs = false;
		acceleration.y = ForBahri.playerGravity;
		FlxSpriteUtil.flicker(this, 0.8, 0.02, true);
		velocity.x += knockback * ((obj.x < x) ? 1 : -1);
		velocity.y -= knockback;
		//hurt(dmg);		
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
			head.animation.play("idle");
			animation.play("walk");
    		if (velocity.x >-10 && velocity.x < 10) animation.play("idle");
    	}else{
    		if (velocity.y < 0){
				animation.play("goUp");
				head.animation.play("up");
			}else{
				animation.play("goDown");
				head.animation.play("down");
			}
    	}
    }
	
	private function handleInput():Void
	{
    	solBas=false;
    	sagBas=false;
    	ustBas=false;

		if (FlxG.keys.justPressed.Z){
			 hasSmg = !hasSmg;
			 rifle.visible = !rifle.visible;
			 pistol.visible = !pistol.visible;
		}
		
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
		

		rifle.x = this.x + 3;
		rifle.y = this.y + 20;
		rifle.angle = mouseAng - 90;
		
		pistol.x = this.x + 3;
		pistol.y = this.y + 20;
		pistol.angle = mouseAng - 90;
		
		head.x = this.x - 6 + (velocity.x * 0.01);
		head.y = this.y - 5 + (velocity.y * 0.01);
		head.angle = mouseAng - 90;

		if (mp.x > this.x){
			pistol.flipY = false;
			rifle.flipY = false;
			head.flipY = false;
			head.offset.y = 0;
			head.origin.y = 29;
			if (head.angle < -60) head.angle = -60;
			if (head.angle > 60) head.angle = 60;
		}else{
			pistol.flipY = true;
			rifle.flipY = true;
			head.flipY = true;
			head.offset.y = -25;
			head.origin.y = 5;
			if (head.angle > -120) head.angle = -120;
			if (head.angle < -230) head.angle = -230;
		}
		
		
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