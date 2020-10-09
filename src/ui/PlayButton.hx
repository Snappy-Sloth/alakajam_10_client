package ui;

private enum PlayBtnStatus {
	Play;
	Pause;
}

class PlayButton extends h2d.Object {

	var currentStatus : PlayBtnStatus = Play;

	var level : Level;

	var spr : HSprite;

	public function new(level:Level) {
		super();

		this.level = level;

		spr = Assets.tiles.h_get("playButtonIdle", this);
		var inter = new h2d.Interactive(spr.tile.width, spr.tile.height, this);

		inter.onClick = (e)->onClick();

		inter.onRelease = inter.onOver = function (e) {
			spr.set(currentStatus == Play ? "playButtonOver" : "restartButtonOver");
		}
		inter.onReleaseOutside = inter.onOut = function (e) {
			spr.set(currentStatus == Play ? "playButtonIdle" : "restartButtonIdle");
		}
		inter.onPush = function (e) {
			spr.set(currentStatus == Play ? "playButtonPress" : "restartButtonPress");
		}
	}

	public function onClick() {
		switch (currentStatus) {
			case Play:
				currentStatus = Pause;
				spr.set("restartButtonIdle");
				level.playBtnPressed();
				case Pause:
				level.resetShips();
		}
	}

	public function reset() {
		currentStatus = Play;
		spr.set("playButtonIdle");
	}

}