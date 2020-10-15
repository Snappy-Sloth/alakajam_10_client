package ui;

private enum PlayBtnStatus {
	Play;
	Pause;
}

class PlayButton extends h2d.Layers {

	public var wid(default, null) : Int;
	public var hei(default, null) : Int;

	var currentStatus : PlayBtnStatus = Play;

	var level : Level;

	var spr : HSprite;
	var text : h2d.Text;

	public function new(level:Level) {
		super();

		this.level = level;

		spr = Assets.tiles.h_get("playButtonIdle", this);
		this.add(spr, 1);

		wid = Std.int(spr.tile.width);
		hei = Std.int(spr.tile.height);

		var inter = new h2d.Interactive(wid, hei);
		this.add(inter, 0);

		text = new h2d.Text(Assets.fontOeuf26);
		text.text = "LAUNCH";
		text.textColor = 0xfffbc2;
		text.setPosition(Std.int((wid/2)-(text.textWidth/2)), Std.int((hei/2)-(text.textHeight/2)));
		text.dropShadow = {dx: 0, dy: 2, alpha: 0.5, color: 0x141013};
		this.add(text, 2);

		inter.onClick = (e)->onClick();

		inter.onRelease = inter.onOver = function (e) {
			text.y = Std.int((hei/2)-(text.textHeight/2));
			spr.set(currentStatus == Play ? "playButtonOver" : "restartButtonOver");
			Assets.CREATE_SOUND(hxd.Res.sfx.overButton, OverButton);
		}
		inter.onReleaseOutside = inter.onOut = function (e) {
			text.y = Std.int((hei/2)-(text.textHeight/2));
			spr.set(currentStatus == Play ? "playButtonIdle" : "restartButtonIdle");
		}
		inter.onPush = function (e) {
			text.y = Std.int((hei/2)-(text.textHeight/2) + 3);
			spr.set(currentStatus == Play ? "playButtonPress" : "restartButtonPress");
			Assets.CREATE_SOUND(hxd.Res.sfx.clickButton, ClickButton);
		}
	}

	public function onClick() {
		switch (currentStatus) {
			case Play:
				currentStatus = Pause;
				spr.set("restartButtonIdle");
				text.text = "RESET";
				text.setPosition(Std.int((wid/2)-(text.textWidth/2)), Std.int((hei/2)-(text.textHeight/2)));
				level.playBtnPressed();
				case Pause:
				level.resetShips();
		}
	}

	public function reset() {
		currentStatus = Play;
		text.text = "LAUNCH";
		text.setPosition(Std.int((wid/2)-(text.textWidth/2)), Std.int((hei/2)-(text.textHeight/2)));
		spr.set("playButtonIdle");
	}

}