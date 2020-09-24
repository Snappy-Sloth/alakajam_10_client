import ui.EndCampaignScreen;
import ui.Hud;
import dn.Process;
import hxd.Key;

class Game extends Process {
	public static var ME : Game;

	public var ca : dn.heaps.Controller.ControllerAccess;
	public var fx : Fx;
	public var scroller : h2d.Layers;
	public var level : Level;
	public var hud : ui.Hud;

	public var score(default, null): Float;

	var levelsToDo : Array<Data.Campaign> = [];

	public function new(levelsToDo:Array<Data.Campaign>) {
		super(Main.ME);
		ME = this;

		this.levelsToDo = levelsToDo;

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
		level = new Level(levelsToDo.shift());
		fx = new Fx();
		hud = new ui.Hud(level.wid, level.hei);
	}

	public function restartLevel(lvlData:Data.Campaign) {
		level = new Level(lvlData);
		fx = new Fx();
		hud = new ui.Hud(level.wid, level.hei);
	}

	public function levelVictory() {
		score += level.currentScore;
		hud.destroy();
		if (levelsToDo.length > 0)
			new ui.EndLevelScreen();
		else
			new ui.EndCampaignScreen();	
		level.destroy();
	}

	public function onCdbReload() {
	}

	public function showPopup(str:String) {
		new Popup(str);
	}

	override function onResize() {
		super.onResize();
		scroller.setScale(Const.SCALE);
	}

	override function onDispose() {
		super.onDispose();

 		fx.destroy();

		ME = null;
	}

	override function update() {
		super.update();

		if( !ui.Console.ME.isActive() && !ui.Modal.hasAny() ) {
			#if hl
			// Exit
			if( ca.isKeyboardPressed(Key.ESCAPE) )
				if( !cd.hasSetS("exitWarn",3) )
					trace(Lang.t._("Press ESCAPE again to exit."));
				else
					hxd.System.exit();
			#end
		}
	}
}

