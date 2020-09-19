class Level extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;

	public var wid(get,never) : Int; inline function get_wid() return 16;
	public var hei(get,never) : Int; inline function get_hei() return 16;

	var arMapTile : Array<MapTile>;
	var wrapperMapTile : h2d.Layers;

	var width : Int;
	var height : Int;

	var rightArrow : Arrow;
	var leftArrow : Arrow;

	public function new(w, h) {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);

		createLevel(w, h);

		var ship = new Ship(this);
		arMapTile[0].addShipToRoad(ship);
	}

	override function onResize() {
		super.onResize();
		
		wrapperMapTile.setPosition(((w()/Const.SCALE-width*Const.MAP_TILE_SIZE)/2)+Const.MAP_TILE_SIZE/2,
									((h()/Const.SCALE-height*Const.MAP_TILE_SIZE)/2)+Const.MAP_TILE_SIZE/2);
	}

	public function createLevel(w, h) {
		arMapTile = [];
		width = w;
		height = h;

		wrapperMapTile = new h2d.Layers(root);
		// root.add(wrapperMapTile, Const.DP_MAIN);

		for (i in 0...width) {
			for (j in 0...height) {
				var mapTile = new MapTile(i, j, this);
				wrapperMapTile.add(mapTile, Const.DP_MAIN);
				arMapTile.push(mapTile);
			}
		}

		rightArrow = new Arrow(true);
		leftArrow = new Arrow(false);
		wrapperMapTile.add(rightArrow, Const.DP_UI);
		wrapperMapTile.add(leftArrow, Const.DP_UI);
	}

	public function addArrows(mapTile:MapTile) {
		rightArrow.show(mapTile);
		leftArrow.show(mapTile);
	}

	public function removeArrows(mapTile:MapTile) {
		rightArrow.hide();
		leftArrow.hide();
	}

	public function checkOtherTiles(mapTile:MapTile) {
		for (mt in arMapTile) {
			if (mt != mapTile && mt.selected) {
				exchangeTiles(mt, mapTile);
				removeArrows(mapTile);
				return true;
			}
		}
		return false;
	}

	public function exchangeTiles(mt1:MapTile, mt2:MapTile) {
		var mapTile1cx = mt1.cx;
		var mapTile1cy = mt1.cy;

		mt1.cx = mt2.cx;
		mt1.cy = mt2.cy;
		mt2.cx = mapTile1cx;
		mt2.cy = mapTile1cy;

		mt1.setPosition(mt1.cx*Const.MAP_TILE_SIZE, mt1.cy*Const.MAP_TILE_SIZE);
		mt2.setPosition(mt2.cx*Const.MAP_TILE_SIZE, mt2.cy*Const.MAP_TILE_SIZE);

		mt1.unSelect();
		mt2.unSelect();
	}

	public inline function isValid(cx,cy) return cx>=0 && cx<wid && cy>=0 && cy<hei;
	public inline function coordId(cx,cy) return cx + cy*wid;

	override function postUpdate() {
		super.postUpdate();
	}
}