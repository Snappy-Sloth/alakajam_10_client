package ui;

class MenuButton extends Button {

    public function new(str:String, onClick:Void->Void) {
		super("menuButton", str, onClick);
    }
}