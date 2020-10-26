package ui;

import dn.heaps.HParticle;

class EndLevelScreen extends dn.Process {

	public static var ME : EndLevelScreen;

	var mainFlow : h2d.Flow;
	var mask : h2d.Mask;
	var flow : h2d.Flow;
	var bgFlow : h2d.ScaleGrid;
	var endLevelText : h2d.Text;
	var scoreText : h2d.Text;
	var newHS : HSprite;
	var totalScoreText : h2d.Text;
	var nextLevelBtn : ButtonMenu;
	
	var pool : ParticlePool;
	var topAddSb       : h2d.SpriteBatch;

	var controlLock = false;
	
	var cinematic : dn.Cinematic;

	public function new() {
		super(Game.ME);

		createRoot();

		ME = this;

		cinematic = new dn.Cinematic(Const.FPS);

		mainFlow = new h2d.Flow(root);
		mainFlow.layout = Vertical;
		mainFlow.horizontalAlign = Middle;
		mainFlow.verticalSpacing = 30;

		mask = new h2d.Mask(1, 1, mainFlow);

		flow = new h2d.Flow(mask);
		flow.layout = Vertical;
		flow.verticalSpacing = 10;
		flow.horizontalAlign = Middle;
		flow.padding = 20;

		pool = new ParticlePool(Assets.tiles.tile, 2048, Const.FPS);
		
		bgFlow = new h2d.ScaleGrid(Assets.tiles.getTile("bgUIsg"), 11, 11, flow);
		flow.getProperties(bgFlow).isAbsolute = true;
        
        endLevelText = new h2d.Text(Assets.fontOeuf26, flow);
		endLevelText.text = 'Level ${Game.ME.level.getLevelNumber()} completed!';
		endLevelText.alpha = 0;
		endLevelText.dropShadow = {dx: 0, dy: 2, alpha: 1, color: 0x895515};

		flow.addSpacing(10);
		
		scoreText = new h2d.Text(Assets.fontOeuf13, flow);
		scoreText.text = 'Moves: ${Std.int(Game.ME.level.currentScore)}';
		scoreText.dropShadow = {dx: 0, dy: 1, alpha: 1, color: 0x895515};
		
		flow.addSpacing(5);

		if (Const.GET_HIGHSCORE_ON_LEVEL(Game.ME.level.getLevelNumber()) < Game.ME.level.currentScore) {
			newHS = Assets.tiles.h_get("newHighscore", flow);
			newHS.alpha = 0;
			flow.getProperties(newHS).isAbsolute = true;
		}

		var bar = Assets.tiles.h_get("separationBar", flow);
		
		totalScoreText = new h2d.Text(Assets.fontOeuf13, flow);
		totalScoreText.text = 'Current Campaign Moves: ${Std.int(Game.ME.score)}';
		totalScoreText.dropShadow = {dx: 0, dy: 1, alpha: 1, color: 0x895515};

		topAddSb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		topAddSb.blendMode = Add;
		topAddSb.hasRotationScale = true;

		nextLevelBtn = new ButtonMenu("Next Level", onClickBtn);
		mainFlow.addChild(nextLevelBtn);

		Const.PLAYER_DATA.scores[Game.ME.level.getLevelNumber()] = Std.int(Game.ME.level.currentScore);
		Const.SAVE_PROGRESS();

		onResize();

		mask.y -= h() / Const.SCALE;
		scoreText.x -= w()/Const.SCALE;
		bar.x -= w()/Const.SCALE;
		totalScoreText.x -= w()/Const.SCALE;
		nextLevelBtn.y += h()/Const.SCALE;

		cinematic.create({
			250;
			tw.createS(mask.y, mask.y + h() / Const.SCALE, 0.3).end(()->cinematic.signal());
			end;
			100;
			tw.createS(endLevelText.alpha, 1, 0.5).end(()->cinematic.signal());
			end;
			tw.createS(scoreText.x, scoreText.x+(w()/Const.SCALE), 0.2).end(()->cinematic.signal());
			end;
			Assets.CREATE_SOUND(hxd.Res.sfx.popUI, PopUI);
			300;
			if (newHS != null) {
				tw.createS(newHS.alpha, 1, 0.2).end(()->cinematic.signal());
				end;
				fxHighscore();
				500;
			}
			tw.createS(bar.x, bar.x+(w()/Const.SCALE), 0.2).end(()->cinematic.signal());
			end;
			200;
			tw.createS(totalScoreText.x, totalScoreText.x+(w()/Const.SCALE), 0.2).end(()->cinematic.signal());
			end;
			Assets.CREATE_SOUND(hxd.Res.sfx.popUI, PopUI);
			tw.createS(nextLevelBtn.y, nextLevelBtn.y-(h()/Const.SCALE), 0.5);
		});
	}

	public inline function allocTopAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topAddSb, t, x, y);
	}

	public inline function getTile(id:String) : h2d.Tile {
		return Assets.tiles.getTileRandom(id);
	}

	function fxHighscore() {
		var pos = root.globalToLocal(newHS.localToGlobal());
		for (i in 0...100) {
			var p = allocTopAdd(getTile("fxDot"), pos.x + rnd(0, newHS.tile.width), pos.y + rnd(0, newHS.tile.height));
			p.colorize(0xfffc40);
			p.moveAng(-rnd(0, Math.PI), rnd(1, 2));
			p.scale = rnd(1, 2);
			p.gy = 0.05;
			p.lifeS = rnd(0.25, 1.5);
		}
	}

	public function onClickBtn() {
		if (controlLock) return;
		controlLock = true;
		cinematic.create({
			tw.createS(mask.y, mask.y-(h()/Const.SCALE), 0.5);
			tw.createS(nextLevelBtn.y, nextLevelBtn.y+(h()/Const.SCALE), 0.5).end(()->cinematic.signal());
			end;
			this.destroy();
			Game.ME.goToNextLevel();
		});
	}

	override function onDispose() {
		super.onDispose();

		ME = null;
    }
    
    override function onResize() {
		super.onResize();
		
		root.setScale(Const.SCALE);

		flow.reflow();
		
		bgFlow.width = mask.width = flow.outerWidth;
		bgFlow.height = mask.height = flow.outerHeight;

		if (newHS != null)
			newHS.setPosition(scoreText.x + scoreText.textWidth + 3, Std.int(scoreText.y - (newHS.tile.height * 0.5)));

		mainFlow.reflow();
		mainFlow.setPosition(Std.int((w() / Const.SCALE) - mainFlow.outerWidth) >> 1, Std.int((h() / Const.SCALE) - mainFlow.outerHeight) >> 1);
	}

	override function update() {
		super.update();

		pool.update(tmod);

		cinematic.update(tmod);
	}
}