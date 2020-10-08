package ui;

class ButtonMenu extends Button {

    public function new(str:String, onClick:Void->Void) {
        super("button", str, onClick);
    }
}