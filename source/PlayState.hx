package;

import flixel.FlxState;
import flixel.effects.particles.FlxEmitter;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.FlxObject;

class PlayState extends FlxState
{
	public var player:Player;
	public var map:FlxOgmoLoader;
	private var tileMap:FlxTilemap;
	private var door:Door;
	
	public var bullets:FlxTypedGroup<Bullet>;
	public var cages:FlxTypedGroup<BirdCage>;
	private var crabs:FlxTypedGroup<Crab>;
	public var rockies:FlxTypedGroup<Rocky>;
	private var platforms:FlxTypedGroup<Platform>;

	private var collideWithMap:FlxGroup;
	private var overlapWithBullets:FlxGroup;
	
	private var crabGibs:FlxEmitter;
	private var rockyGibs:FlxEmitter;
	
	function placeEntities(entityName:String, entityData:Xml):Void
	{
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		
		switch entityName {
			case "player":
			player.setPosition(x, y);
			case "door":
			door.setPosition(x, y);
			case "cage":
			cages.add(new BirdCage(x, y, this));
			case "crab":
			crabs.add(new Crab(x, y, player, tileMap, crabGibs));
			case "rocky":
			rockies.add(new Rocky(x, y, player, tileMap, rockyGibs));
			case "platform":
			var vis:String = entityData.get("visible");
			platforms.add(new Platform(x, y, vis, player)); 
		}
	}
	public function stairCallBack(Tile:FlxObject, Object:FlxObject)
	{
		player.onStairsCol = true;
		if ((FlxG.keys.pressed.W || FlxG.keys.pressed.S) && !player.onStairs){
			player.onStairs = true;
			player.x = Tile.x + 6;
			player.acceleration.y = 0;
			player.velocity.y = 0;
			player.velocity.x = 0;
		}
	}
	
	override public function create():Void
	{
		super.create();
		FlxG.debugger.visible = true;
		FlxG.cameras.bgColor = 0x7DA0FF;
		FlxG.camera.antialiasing = false;
		FlxG.worldBounds.width = 2048;
		FlxG.worldBounds.height = 640;
		
		map = new FlxOgmoLoader(Main.levels[Main.currentLevel]);
		
		tileMap = map.loadTilemap(AssetPaths.tileset__png, 32, 32, "walls");
		tileMap.setTileProperties(7, FlxObject.NONE, stairCallBack, Player);
		tileMap.setTileProperties(13, FlxObject.NONE);
		add(tileMap);
		
		crabGibs = new FlxEmitter();
		crabGibs.angularVelocity.set(-600, 600);
		crabGibs.acceleration.set(0, 350);
		crabGibs.launchMode = FlxEmitterMode.SQUARE;
		crabGibs.loadParticles(AssetPaths.crabGibs__png, 30, 10, true);
		
		rockyGibs = new FlxEmitter();
		rockyGibs.angularVelocity.set(-600, 600);
		rockyGibs.acceleration.set(0, 350);
		rockyGibs.launchMode = FlxEmitterMode.SQUARE;
		rockyGibs.loadParticles(AssetPaths.rockyGibs__png, 30, 10, true);

		bullets = new FlxTypedGroup<Bullet>(ForBahri.maxBullet);
		var bulletHolder:Bullet;
		for (i in 0...ForBahri.maxBullet)
		{
			bulletHolder = new Bullet();
			bullets.add(bulletHolder);
		}
		
		player = new Player(this);
		add(player);
		add(player.rifle);
		add(player.pistol);
		add(player.head);
		add(bullets);

		cages = new FlxTypedGroup<BirdCage>();
		crabs = new FlxTypedGroup<Crab>();
		platforms = new FlxTypedGroup<Platform>();
		rockies = new FlxTypedGroup<Rocky>();
		door = new Door(player);
		
		map.loadEntities(placeEntities, "entities");

		
		add(cages);
		add(door);
		add(crabs);
		add(platforms);
		add(rockies);
		
		add(crabGibs);
		add(rockyGibs);
		
		collideWithMap = new FlxGroup();
		collideWithMap.add(player);
		collideWithMap.add(bullets);
		collideWithMap.add(crabs);

		
		overlapWithBullets = new FlxGroup();
		overlapWithBullets.add(crabs);
		overlapWithBullets.add(rockies);
	}

	override public function update(elapsed:Float):Void
	{
		Main.timePassed += elapsed;
		FlxG.collide(collideWithMap, tileMap);
		FlxG.collide(collideWithMap, platforms);
		FlxG.overlap(bullets, overlapWithBullets, bulletOverlap);
		
		if (FlxG.keys.pressed.R) FlxG.resetGame();
		
		super.update(elapsed);
	}
	
	private function bulletOverlap(bullet:FlxObject, enemy:Enemy):Void
	{
		//enemy.velocity.x  += bullet.velocity.x  * ForBahri.crabKnockbackResistanceX;
		//enemy.velocity.y  = bullet.velocity.y * ForBahri.crabKnockbackResistanceY;
		
		//enemy.hurt(bullet.health);
		enemy.getHit(bullet);
		bullet.kill();
	}
}