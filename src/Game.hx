import ui.EndCampaignScreen;
import ui.Hud;
import dn.Process;
import hxd.Key;

class Game extends Process {
	public static var ME : Game;

	public var ca : dn.heaps.Controller.ControllerAccess;
	public var fx : Fx;
	public var camera : Camera;
	public var scroller : h2d.Layers;
	public var level : Level;
	public var hud : ui.Hud;

	// var width(get, never) : Int; inline function get_width() return lvlData.width;
	// var height(get, never) : Int; inline function get_height() return lvlData.height;

	public var numberLife(default, null) : Int;
	public var score(default, null): Int;

	var levelsToDo : Array<Data.Campaign> = [];

	public function new(levelsToDo:Array<Data.Campaign>) {
		super(Main.ME);
		ME = this;

		this.levelsToDo = levelsToDo;

		numberLife = 3;
		score = 0;

		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_BG);

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_BG);
		scroller.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

		goToNextLevel();

		onResize();
	}

	public function goToNextLevel() {
		// camera = new Camera();
		level = new Level(levelsToDo.shift());
		fx = new Fx();
		hud = new ui.Hud(level.wid, level.hei);
	}

	public function restartLevel(lvlData:Data.Campaign) {
		level = new Level(lvlData);
		fx = new Fx();
		hud = new ui.Hud(level.wid, level.hei);
	}

	public function looseLife() {
		numberLife--;
		hud.looseLife();
		hud.destroy();
		if (numberLife == 0) {
			new ui.GameOverScreen();
		}
		else {
			new ui.LooseLifeScreen(level.lvlData);
		}
		level.destroy();
	}

	public function levelVictory() {
		level.destroy();
		hud.destroy();
		if (levelsToDo.length > 0)
			new ui.EndLevelScreen();
		else
			new ui.EndCampaignScreen();	
	}

	public function onCdbReload() {
	}

	override function onResize() {
		super.onResize();
		scroller.setScale(Const.SCALE);
	}

	function gc() {
		if( Entity.GC==null || Entity.GC.length==0 )
			return;

		for(e in Entity.GC)
			e.dispose();
		Entity.GC = [];
	}

	override function onDispose() {
		super.onDispose();

		fx.destroy();
		for(e in Entity.ALL)
			e.destroy();
		gc();

		ME = null;
	}

	override function preUpdate() {
		super.preUpdate();

		for(e in Entity.ALL) if( !e.destroyed ) e.preUpdate();
	}

	override function postUpdate() {
		super.postUpdate();

		for(e in Entity.ALL) if( !e.destroyed ) e.postUpdate();
		gc();
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		for(e in Entity.ALL) if( !e.destroyed ) e.fixedUpdate();
	}

	override function update() {
		super.update();

		for(e in Entity.ALL) if( !e.destroyed ) e.update();

		if( !ui.Console.ME.isActive() && !ui.Modal.hasAny() ) {
			#if hl
			// Exit
			if( ca.isKeyboardPressed(Key.ESCAPE) )
				if( !cd.hasSetS("exitWarn",3) )
					trace(Lang.t._("Press ESCAPE again to exit."));
				else
					hxd.System.exit();

				// Restart
				// #if debug
				// if( ca.selectPressed() )
				// 	Main.ME.startGame();
				// #end
			#end

		}
	}
}

