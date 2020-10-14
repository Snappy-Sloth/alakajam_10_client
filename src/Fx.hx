import dn.heaps.HParticle;


class Fx extends dn.Process {
	public var pool : ParticlePool;

	public var bgAddSb    : h2d.SpriteBatch;
	public var bgNormalSb    : h2d.SpriteBatch;
	public var topAddSb       : h2d.SpriteBatch;
	public var topNormalSb    : h2d.SpriteBatch;

	var game(get,never) : Game; inline function get_game() return Game.ME;

	public function new() {
		super(Game.ME);

		pool = new ParticlePool(Assets.tiles.tile, 2048, Const.FPS);

		bgAddSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.level.wrapperGameZone.add(bgAddSb, Const.DP_WATERFX);
		bgAddSb.blendMode = Add;
		bgAddSb.hasRotationScale = true;

		bgNormalSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.level.wrapperGameZone.add(bgNormalSb, Const.DP_WATERFX);
		bgNormalSb.hasRotationScale = true;

		topNormalSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.level.wrapperGameZone.add(topNormalSb, Const.DP_FX_FRONT);
		topNormalSb.hasRotationScale = true;

		topAddSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.level.wrapperGameZone.add(topAddSb, Const.DP_FX_FRONT);
		topAddSb.blendMode = Add;
		topAddSb.hasRotationScale = true;
	}

	override public function onDispose() {
		super.onDispose();

		pool.dispose();
		bgAddSb.remove();
		bgNormalSb.remove();
		topAddSb.remove();
		topNormalSb.remove();
	}

	public function clear() {
		pool.killAll();
	}

	public inline function allocTopAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topAddSb, t, x, y);
	}

	public inline function allocTopNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topNormalSb, t,x,y);
	}

	public inline function allocBgAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgAddSb, t,x,y);
	}

	public inline function allocBgNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgNormalSb, t,x,y);
	}

	public inline function getTile(id:String) : h2d.Tile {
		return Assets.tiles.getTileRandom(id);
	}

	public function killAll() {
		pool.killAll();
	}

	public function reachExit(mt:MapTile, ep:EP) {
		for (i in 0...5) {
			var color = Color.randomColor();
	
			var p = allocTopAdd(getTile("fxDot"), mt.x + Road.getEpX(ep) - (Const.MAP_TILE_SIZE >> 1), mt.y + Road.getEpY(ep) - (Const.MAP_TILE_SIZE >> 1));
			p.dy = -2;
			p.dx = rnd(0.1, 0.3, true);
			p.colorize(color);
			p.scale = 3;
			p.lifeS = rnd(0.15, 0.4);
			p.delayS = i * 0.1;
			p.onUpdate = function (p) {
				var np = allocTopAdd(getTile("fxDot"), p.x, p.y);
				np.colorize(color);
				np.lifeS = 0.2;
			}
			p.onKill = function() {
				for (i in 0...20) {
					var np = allocTopAdd(getTile("fxDot"), p.x, p.y);
					np.moveAng(rnd(0, Math.PI, true), rnd(0.5, 1));
					np.colorize(color);
					np.lifeS = rnd(0.5, 1);
					np.frict = 0.99;
					np.ds = 0.1;
					np.dsFrict = 0.97;
					np.rotation = rnd(0, Math.PI, true);
					np.dr = rnd(0.1, 0.2);
					np.scale = rnd(1, 2);
				}
			}
		}
	}

	public function explosion(x:Float, y:Float) {
		for (i in 0...10) {
			var p = allocBgNormal(getTile("backExplosion"), x, y);
			p.rotation = rnd(0, Math.PI * 2);
			p.moveAng(p.rotation, rnd(0.1, 0.15));
			p.alpha = rnd(0.5, 0.75);
			p.scale = 0;
			p.ds = rnd(0.1, 0.15);
			p.dsFrict = 0.9;
			p.playAnimAndKill(Assets.tiles, "backExplosion", rnd(0.05, 0.1));
			p.lifeS = 2;
			p.delayS = 0.05;
		}
		var p = allocBgNormal(getTile("fxCircle"), x, y);
		p.lifeS = 0.1;
	}
	
	public function showShipWaterMove(s:Ship, rotation:Float) {
		var p = allocBgAdd(getTile("shipWaterMove"), s.root.x, s.root.y);
		p.playAnimAndKill(Assets.tiles, "shipWaterMove", 0.1);
		p.alpha = 0.75;
		p.rotation = rotation;
	}

	public function markerCase(cx:Int, cy:Int, ?sec=3.0, ?c=0xFF00FF) {
		#if debug
		var p = allocTopAdd(getTile("fxCircle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.lifeS = sec;

		var p = allocTopAdd(getTile("pixel"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(2);
		p.lifeS = sec;
		#end
	}

	public function markerFree(x:Float, y:Float, ?sec=3.0, ?c=0xFF00FF) {
		#if debug
		var p = allocTopAdd(getTile("fxDot"), x,y);
		p.setCenterRatio(0.5,0.5);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(3);
		p.lifeS = sec;
		#end
	}

	public function markerText(cx:Int, cy:Int, txt:String, ?t=1.0) {
		#if debug
		var tf = new h2d.Text(Assets.fontPixel, topNormalSb);
		tf.text = txt;

		var p = allocTopAdd(getTile("fxCircle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.colorize(0x0080FF);
		p.alpha = 0.6;
		p.lifeS = 0.3;
		p.fadeOutSpeed = 0.4;
		p.onKill = tf.remove;

		tf.setPosition(p.x-tf.textWidth*0.5, p.y-tf.textHeight*0.5);
		#end
	}

	public function flashBangS(c:UInt, a:Float, ?t=0.1) {
		var e = new h2d.Bitmap(h2d.Tile.fromColor(c,1,1,a));
		game.root.add(e, Const.DP_FX_FRONT);
		e.scaleX = game.w();
		e.scaleY = game.h();
		e.blendMode = Add;
		game.tw.createS(e.alpha, 0, t).end( function() {
			e.remove();
		});
	}

	override function update() {
		super.update();

		pool.update(game.tmod);
	}
}