import dn.heaps.slib.*;

class Assets {
	
	public static var fontPixel : h2d.Font;
	public static var fontStapler15 : h2d.Font;
	public static var fontOeuf13 : h2d.Font;
	public static var fontOeuf26 : h2d.Font;
	public static var tiles : SpriteLib;

	static var initDone = false;

	static var MUSIC : dn.heaps.Sfx;

	static var fadeTw : Tween;

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

	public static function PLAY_MUSIC(defaultVolume:Float = 1) {
		MUSIC = Assets.CREATE_SOUND(hxd.Res.music.theme, Music, true, true, true);
		MUSIC.group.volume = Const.OPTIONS_DATA.MUSIC_VOLUME * GET_VOLUME(Music) * defaultVolume;
	}

	public static function FADE_MUSIC_VOLUME(volumeRatio:Float, duration:Float = 1) {
		if (MUSIC == null) {
			Assets.PLAY_MUSIC(volumeRatio);
			return;
		}

		var t : Float = MUSIC.group.volume;

		if (fadeTw != null && !fadeTw.done)
			fadeTw.endWithoutCallbacks();

		fadeTw = Main.ME.tw.createS(t, Const.OPTIONS_DATA.MUSIC_VOLUME * GET_VOLUME(Music) * volumeRatio, duration);
		fadeTw.onUpdate = ()->MUSIC.group.volume = t;
	}

	public static function UPDATE_MUSIC_VOLUME() {
		if (MUSIC != null) {
			MUSIC.group.volume = Const.OPTIONS_DATA.MUSIC_VOLUME * GET_VOLUME(Music);
			Const.updateUserSettings();
		}
	}

	public static function UPDATE_SFX_VOLUME() {
		Const.updateUserSettings();
	}

	public static function CREATE_SOUND(sndFile:hxd.res.Sound, vg:VolumeGroup, loop:Bool = false, playNow:Bool = true, isMusic:Bool = false) : dn.heaps.Sfx {
		var snd = new dn.heaps.Sfx(sndFile);
		snd.groupId = vg.getIndex();
		dn.heaps.Sfx.setGroupVolume(snd.groupId, GET_VOLUME(vg) * (isMusic ? Const.OPTIONS_DATA.MUSIC_VOLUME : Const.OPTIONS_DATA.SFX_VOLUME));
		playNow ? snd.play(loop) : snd.stop();

		return snd;
	}
}