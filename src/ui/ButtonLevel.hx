package ui;

class ButtonLevel extends Button {

    public function new(str:String, onClick:Void->Void) {
        super(50, 25, str, onClick);
    }
}