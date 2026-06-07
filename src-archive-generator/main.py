from enum import Enum

from textual.app import App, ComposeResult
from textual.containers import CenterMiddle, Container
from textual.screen import Screen
from textual.widgets import Button, Header

class State(Enum):
    MAIN_MENU = 0,
    CREATE_USER = 1,

class MainMenu(Screen):
    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")
        yield CenterMiddle(Button(label = "New Archive", id = "new_archive"))
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "new_archive":
            app.set_state(State.CREATE_USER)
            app.install_screen(CreateUserMenu(), name = "Create User Menu")
            app.switch_screen("Create User Menu")

class CreateUserMenu(Screen):

    class CreateState(Enum):
        NAME = 0,
        EMAIL = 1,

    class SideBar(Container):
        def __init__(self, bar_parent: Screen):
            super().__init__()
            self._parent = bar_parent

        def compose(self) -> ComposeResult:
            yield Button(label = "Set Name", id = "name")
            yield Button(label = "Set Email", id = "email")
            yield Button(label = "Create", id = "create")
        
        def on_button_pressed(self, event: Button.Pressed) -> None:
            if event.button.id == "name":
                self._parent.set_state(self._parent.CreateState.NAME)
            elif event.button.id == "email":
                self._parent.set_state(self._parent.CreateState.EMAIL)

    
    def __init__(self):
        super().__init__()
        self.state = self.CreateState.NAME
        self.side_bar = self.SideBar(self)

    
    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")
        yield self.side_bar
    
    def set_state(self, new_state: CreateState):
        self.state = new_state

class ArchiveGeneratorApp(App):

    def __init__(self):
        super().__init__()
        self.state = State.MAIN_MENU

    BINDINGS = [("d", "toggle_dark", "Toggle dark mode")]        

    def action_toggle_dark(self) -> None:
        """An action to toggle dark mode."""
        self.theme = (
            "textual-dark" if self.theme == "textual-light" else "textual-light"
        )
    
    def set_state(self, new_state: State) -> None:
        self.state = new_state
    
    def on_mount(self) -> None:
        self.install_screen(MainMenu(), name = "Main Menu")
        self.push_screen("Main Menu")

if __name__ == '__main__':
    app = ArchiveGeneratorApp()
    app.run()