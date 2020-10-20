import ui.EndCampaignScreen;
import ui.EndLevelScreen;
import ui.ChooseLevelScreen;
import Data;
import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;

	public function new(s:h2d.Scene) {
		super();
		ME = this;

        createRoot(s);

		// Engine settings
		hxd.Timer.wantedFPS = Const.FPS;
		engine.backgroundColor = 0xff<<24|0x1c2731;
        #if( hl && !debug )
        engine.fullScreen = true;
        #end

		// Resources
		#if(hl && debug)
		hxd.Res.initLocal();
        #else
        hxd.Res.initEmbed();
        #end

        // Hot reloading
		#if debug
        hxd.res.Resource.LIVE_UPDATE = true;
        hxd.Res.data.watch(function() {
            delayer.cancelById("cdb");

            delayer.addS("cdb", function() {
            	Data.load( hxd.Res.data.entry.getBytes().toString() );
            	if( Game.ME!=null )
                    Game.ME.onCdbReload();
            }, 0.2);
        });
		#end

		// Assets & data init
		Assets.init();
		new ui.Console(Assets.fontPixel, s);
		Lang.init("en");
		Data.load( hxd.Res.data.entry.getText() );

		Const.INIT();

		// Start
		new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.fontPixel);
		// delayer.addF( startGame, 1 );
		delayer.addF( startTitleScreen, 1 );

		dn.Process.resizeAll();
	}

	public function startTitleScreen() {
		if (Game.ME != null) {
			Game.ME.destroy();
		}
		
		clean();

		new ui.TitleScreen();
	}

	public function startChooseLevelScreen() {
		clean();

		new ui.ChooseLevelScreen();
	}

	public function showOptions() {
		clean();

		new ui.Options();
	}

	function clean() {
		if( EndCampaignScreen.ME!=null ) {
			EndCampaignScreen.ME.destroy();
		}
		if( ui.TitleScreen.ME!=null ) {
			ui.TitleScreen.ME.destroy();
		}
		if( ChooseLevelScreen.ME!=null ) {
			ChooseLevelScreen.ME.destroy();
		}
		if( EndLevelScreen.ME!=null ) {
			EndLevelScreen.ME.destroy();
		}
	}

	public function startCampaign() {
		clean();

		var levelsToDo = [];

		for (lvl in Data.Campaign.all) {
			levelsToDo.push(lvl);
		}

		startGame(levelsToDo);
		//startGame([levelsToDo[0]]); // For debug only
	}

	public function startOneLevel(level:Data.Campaign) {
		clean();

		startGame([level]);
	}

	public function startGame(levelsToDo:Array<Data.Campaign>) {
		if( Game.ME!=null ) {
			Game.ME.destroy();
			delayer.addF(function() {
				new Game(levelsToDo);
			}, 1);
		}
		else
			new Game(levelsToDo);
	}

	override public function onResize() {
		super.onResize();

		// Auto scaling
		if( Const.AUTO_SCALE_TARGET_WID>0 )
			Const.SCALE = M.ceil( w()/Const.AUTO_SCALE_TARGET_WID );
		else if( Const.AUTO_SCALE_TARGET_HEI>0 )
			Const.SCALE = M.ceil( h()/Const.AUTO_SCALE_TARGET_HEI );

		Const.UI_SCALE = Const.SCALE;
	}

    override function update() {
		Assets.tiles.tmod = tmod;
        super.update();
    }
}