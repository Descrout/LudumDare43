package;

import flixel.FlxState;
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
	public var birds:FlxTypedGroup<Bird>;
	private var crabs:FlxTypedGroup<Crab>;

	private var collideWithMap:FlxGroup;
	private var overlapWithBullets:FlxGroup;
	
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
			crabs.add(new Crab(x, y, player));
		}
	}
	override public function create():Void
	{
		super.create();
		FlxG.debugger.visible = true;
		FlxG.cameras.bgColor = 0x7DA0FF;
		
		map = new FlxOgmoLoader(Main.levels[Main.currentLevel]);
		
		tileMap = map.loadTilemap(AssetPaths.tiles__png, 32, 32, "walls");
		add(tileMap);
		
		var numPlayerBullets:Int = 6;
		bullets = new FlxTypedGroup<Bullet>(numPlayerBullets);
		var bulletHolder:Bullet;
		for (i in 0...numPlayerBullets)
		{
			bulletHolder = new Bullet();
			bullets.add(bulletHolder);
		}
		
		player = new Player(this);
		add(player);
		add(player.gun);
		add(bullets);
		
		birds = new FlxTypedGroup<Bird>();
		cages = new FlxTypedGroup<BirdCage>();
		crabs = new FlxTypedGroup<Crab>();
		door = new Door(player);
		
		map.loadEntities(placeEntities, "entities");
		
		add(cages);
		add(door);
		add(birds);
		add(crabs);
		
		collideWithMap = new FlxGroup();
		collideWithMap.add(player);
		collideWithMap.add(bullets);
		collideWithMap.add(crabs);
		
		overlapWithBullets = new FlxGroup();
		overlapWithBullets.add(crabs);
	}

	override public function update(elapsed:Float):Void
	{
		FlxG.collide(collideWithMap, tileMap);
		FlxG.overlap(bullets, overlapWithBullets, bulletOverlap);
		
		if (FlxG.keys.pressed.R) FlxG.resetGame();
		
		super.update(elapsed);
	}
	
	private function bulletOverlap(bullet:FlxObject, enemy:FlxObject):Void
	{
		enemy.velocity.x  = bullet.velocity.x;
		enemy.velocity.y  = bullet.velocity.y;
		
		enemy.hurt(bullet.health);
		bullet.kill();
	}
}