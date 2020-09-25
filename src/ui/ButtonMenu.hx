package ui;

class ButtonMenu extends Button {

    public function new(str:String, onClick:Void->Void) {
        super(100, 50, "button", str, onClick);
    }
}