package ui;

class Slider extends h2d.Object {

	var isActive = false;

	var value : Float;

	public function new(initialValue:Float = 1, onChange:Float->Void) {
		super();

		value = initialValue;

		var bg = Assets.tiles.h_get("sliderBG");
		this.addChild(bg);

		var gauge = Assets.tiles.h_get("slider");
		gauge.setPosition(2, 2);
		this.addChild(gauge);

		var offsetX = 20;

		var inter = new h2d.Interactive(bg.tile.width + offsetX, bg.tile.height, this);
		inter.x = -(offsetX >> 1);
		// inter.backgroundColor = 0x55FF00FF;

		inter.onPush = function (e) {
			isActive = true;
			inter.onMove(e);
		}

		inter.onReleaseOutside = inter.onRelease = function (e) {
			isActive = false;
		}
		
		inter.onMove = function (e) {
			if (isActive) {
				gauge.scaleX = e.relX < (offsetX >> 1) ? 0 : e.relX > inter.width - (offsetX >> 1) ? 1 : (e.relX - (offsetX >> 1)) / (inter.width - offsetX);
				onChange(gauge.scaleX);
			}
		}

		gauge.scaleX = value;

		inter.onWheel = function (e) {
			if (e.wheelDelta > 0)
				value -= 0.05;
			if (e.wheelDelta < 0)
				value += 0.05;

			value = hxd.Math.clamp(value, 0, 1);

			gauge.scaleX = value;

			onChange(gauge.scaleX);
		}
	}

}