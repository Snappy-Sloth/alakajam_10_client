import dn.heaps.slib.*;

class Assets {
	public static var fontPixel : h2d.Font;
	public static var fontStapler15 : h2d.Font;
	public static var fontOeuf13 : h2d.Font;
	public static var tiles : SpriteLib;

	static var initDone = false;
	public static function init() {
		if( initDone )
			return;
		initDone = true;

		fontPixel = hxd.Res.fonts.minecraftiaOutline.toFont();
		fontStapler15 = hxd.Res.fonts.chevyray_stapler_regular_15.toFont();
		fontOeuf13 = hxd.Res.fonts.chevyray_oeuf_regular_13.toFont();
		tiles = dn.heaps.assets.Atlas.load("atlas/ss.atlas");
	}
}