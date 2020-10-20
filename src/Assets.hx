import dn.heaps.slib.*;

class Assets {
	
	public static var fontPixel : h2d.Font;
	public static var fontStapler15 : h2d.Font;
	public static var fontOeuf13 : h2d.Font;
	public static var fontOeuf26 : h2d.Font;
	public static var tiles : SpriteLib;

	static var initDone = false;
	public static function init() {
		if( initDone )
			return;
		initDone = true;

		fontPixel = hxd.Res.fonts.minecraftiaOutline.toFont();
		fontStapler15 = hxd.Res.fonts.chevyray_stapler_regular_15.toFont();
		fontOeuf13 = hxd.Res.fonts.chevyray_oeuf_regular_13.toFont();
		fontOeuf26 = hxd.Res.fonts.chevyray_oeuf_regular_26.toFont();
		tiles = dn.heaps.assets.Atlas.load("atlas/ss.atlas");
	}

	public static function GET_VOLUME(vg:VolumeGroup) {
		return dn.Lib.getEnumMetaFloat(vg, "volume");
	}

	public static function CREATE_SOUND(sndFile:hxd.res.Sound, vg:VolumeGroup, loop:Bool = false, playNow:Bool = true, isMusic:Bool = false) {
		var snd = new dn.heaps.Sfx(sndFile);
		snd.groupId = vg.getIndex();
		dn.heaps.Sfx.setGroupVolume(snd.groupId, GET_VOLUME(vg) * (isMusic ? Const.OPTIONS_DATA.MUSIC_VOLUME : Const.OPTIONS_DATA.SFX_VOLUME));
		playNow ? snd.play(loop) : snd.stop();

		return snd;
	}
}