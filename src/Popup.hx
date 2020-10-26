class Popup extends dn.Process {

	public static var ME : Popup;

	public function new(str:String) {
		super(Game.ME);

		if (ME != null)
			ME.destroy();

		ME = this;

		createRootInLayers(parent.root, Const.DP_UI);
		
		var text = new h2d.Text(Assets.fontPixel);
		root.add(text, 1);
		text.text = str;
		// text.setScale(2);
		text.maxWidth = ((w() / Const.SCALE) * 0.75) / text.scaleX;
		text.textAlign = Center;
		
		var bg = new h2d.Bitmap(h2d.Tile.fromColor(0, Std.int((w() / Const.SCALE) * 0.80), Std.int(text.textHeight * text.scaleY * 1.5), 0.5));
		root.add(bg, 0);

		text.x = (bg.tile.width - text.maxWidth * text.scaleX) * 0.5;
		text.y = (bg.tile.height - text.textHeight * text.scaleY) * 0.5;

		root.x = Std.int(w() - bg.tile.width * Const.SCALE) >> 1;

		root.y -= h() * 0.2;
		tw.createS(root.y, 0, 0.5);
		
		delayer.addS(function () {
			tw.createS(root.y, -h() * 0.2, 0.5).onEnd = ()->this.destroy();
		}, 2 + str.length * 0.04);

		onResize();
	}

	override function onResize() {
		super.onResize();

		root.setScale(Const.SCALE);
	}

	override function onDispose() {
		super.onDispose();

		if (ME == this)
			ME = null;
	}
}