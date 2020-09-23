package ui;

class ButtonMenu extends Button {

    public function new(str:String, onClick:Void->Void) {
        super(100, 50, str, onClick);

        var button = Assets.tiles.h_get("button");
        this.add(button, 1);
    }
}