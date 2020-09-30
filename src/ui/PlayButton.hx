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

		spr = Assets.tiles.h_get("play", this);
		var inter = new h2d.Interactive(spr.tile.width, spr.tile.height, this);

		inter.onClick = (e)->onClick();
	}

	public function onClick() {
		switch (currentStatus) {
			case Play:
				currentStatus = Pause;
				spr.set("restartBtn");
				level.playBtnPressed();
				case Pause:
				level.resetShips();
		}
	}

	public function reset() {
		currentStatus = Play;
		spr.set("play");
	}

}