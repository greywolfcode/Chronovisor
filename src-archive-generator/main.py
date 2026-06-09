# Chronovisor archive generator tool.
# Copyright (C) 2026  greywolfcode
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published byl
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

from enum import Enum

from rich.text import Text

from textual.app import App, ComposeResult
from textual.containers import CenterMiddle, Container, Horizontal, Vertical, VerticalScroll
from textual.screen import ModalScreen, Screen
from textual.widgets import Button, ContentSwitcher, DataTable, Footer, Header, Input, Label

from scripts.id_handeler import IdType

from scripts.archive_handeling import Archive, Message, Person

data = {
    "spaces": {},
    "groups": {}
}

current_uuid = None

class State(Enum):
    MAIN_MENU = 0,
    CREATE_USER = 1,
    HUB = 2,
    CREATE_DM = 3,
    EDIT_PEOPLE = 4,

class MainMenu(Screen):
    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")
        yield CenterMiddle(Button(label = "New Archive", id = "new_archive"))
        yield Footer()    
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "new_archive":
            app.set_state(State.CREATE_USER)
            app.install_screen(CreateUserMenu(), name = "Create User Menu")
            app.switch_screen("Create User Menu")

class CreateUserMenu(Horizontal, Screen):

    CSS_PATH = "styles/create_user_menu.tcss"

    class CreateState(Enum):
        NAME = 0,
        EMAIL = 1,

    class SideBar(Container):

        id = "sidebar"

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
            elif event.button.id == "create":
                self._parent.create_user()

                app.set_state(State.HUB)
                app.install_screen(HubMenu(), name = "Hub Menu")
                app.switch_screen("Hub Menu")

    
    def __init__(self):
        super().__init__()
        self.state = self.CreateState.NAME
        self.side_bar = self.SideBar(self)

        self._name = "Temp Temp"
        self._email = "Temp@temp.temp"
    
    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")

        yield self.side_bar

        with ContentSwitcher(initial="name", id="label_switcher"):
            yield Label("Name:", id="name")
            yield Label("Email:", id="email")

        with ContentSwitcher(initial="name", id="input_switcher"):
            yield Input(placeholder=self._name, id="name")
            yield Input(placeholder=self._email, id="email")
        
        yield Footer()

    def on_input_changed(self, event: Input.Changed):
        if (event.input.id == "name"):
            self._name = event.input.value
        else:
            self._email = event.input.value

    def set_state(self, new_state: CreateState):
        self.state = new_state
        if (self.state == self.CreateState.NAME):
            self.query_one("#label_switcher", ContentSwitcher).current = "name"
            self.query_one("#input_switcher", ContentSwitcher).current = "name"
        else:
            self.query_one("#label_switcher", ContentSwitcher).current = "email"
            self.query_one("#input_switcher", ContentSwitcher).current = "email"
    
    def create_user(self):
        data["user"] = Person(self._name, self._email)

class HubMenu(Screen):

    CSS_PATH = "styles/hub_menu.tcss"

    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")

        yield Button(label = "New Space", id = "new_space")
        yield Button(label = "New DM", id = "new_dm")
        yield Button(label = "Export", id = "export")

        yield Footer()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "new_dm":
            app.set_state(State.CREATE_DM)
            app.install_screen(DMCreationMenu(), name = "DM Creation Menu")
            app.switch_screen("DM Creation Menu")

class DMCreationMenu(Screen):

    CSS_PATH = "styles/create_message_group_menus.tcss"

    class SideBar(Vertical):
        def compose(self) -> ComposeResult:
            yield Button(label = "Edit People", id = "edit_people")
            yield Button(label = "Add Message", id = "add_message")
            yield Button(label = "Finish", id = "finish")

    def __init__(self):
        global current_uuid

        super().__init__()
        self.uuid = IdType.gen_id(IdType.DM)
        self.sidebar = self.SideBar()
        self.editor = Container()

        current_uuid = self.uuid
        data["spaces"][current_uuid] = Archive(self.uuid)
        data["spaces"][current_uuid].add_person(data["user"])
    
    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")

        yield self.sidebar 

        yield Footer()
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "edit_people":
            self.editor = PersonEditingMenu(2) # can't add more prople to DM
            self.mount(self.editor)

class SpaceCreationMenu(Screen):
    def __init__(self):
        super().__init__()
        self.uuid = IdType.gen_id(IdType.Space)

class PersonEditingMenu(VerticalScroll):
    def __init__(self, max_people: int):
        super().__init__()
        self.max_people = max_people
        self.current_row = None

    def compose(self) -> ComposeResult:
        
        yield DataTable()

        yield Horizontal(
            Button("Add person", id = "add_person"),
            Button("Edit Person", id = "edit_person"),
            Button("Remove Person", id = "remove_person")
        )
    
    def on_mount(self) -> None:
        rows = [("name", "email")]
        for person in data["spaces"][current_uuid].people:
            rows.append((person.name, person.email))

        table = self.query_one(DataTable)
        table.add_columns(*rows[0])
        table.cursor_type = "row"
        for number, row in enumerate(rows[1:], start=1):
            label = Text(str(number))
            table.add_row(*row, label=label)
        
        self.disable_buttons()
    
    def on_data_table_row_highlighted(self, event: DataTable.RowHighlighted) -> None:
        self.current_row = event.cursor_row
        
        self.disable_buttons()

    def disable_buttons(self) -> None:
        rows = data["spaces"][current_uuid].people

        if len(rows) >= self.max_people:
            self.query_one("#add_person").disabled = True
        else:
            self.query_one("#add_person").disabled = False

        if len(rows) <= 1:
            self.query_one("#remove_person").disabled = True
        else:
            self.query_one("#remove_person").disabled = False

        if self.current_row != None and self.current_row != 0:
            self.query_one("#edit_person").disabled = False
        else:
            self.query_one("#edit_person").disabled = True

class LicenceScreen(ModalScreen):

    BINDINGS = [("l", "close", "Close Licence")]        

    CSS_PATH = "styles/licence_screen.tcss"

    LICENCE_TEXT = """
    Chronovisor archive generator tool.
    Copyright (C) 2026  greywolfcode

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published byl
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA."""

    def compose(self) -> ComposeResult:
        yield CenterMiddle(
            Label(self.LICENCE_TEXT, id="text"),
            Button(label = "Done", id = "done"),
            id = "popup"
        )
            
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "done":
            self.close()

    def action_close(self):
        self.close()
    
    def close(self):
        app.pop_screen()

class ArchiveGeneratorApp(App):

    def __init__(self):
        super().__init__()
        self.state = State.MAIN_MENU

    BINDINGS = [("d", "toggle_dark", "Toggle dark mode"), ("l", "show_licence", "Show Licence")]        

    def action_toggle_dark(self) -> None:
        """An action to toggle dark mode."""
        self.theme = (
            "textual-dark" if self.theme == "textual-light" else "textual-light"
        )
    
    def action_show_licence(self):
        self.push_screen(LicenceScreen())
    
    def set_state(self, new_state: State) -> None:
        self.state = new_state
    
    def on_mount(self) -> None:
        self.install_screen(MainMenu(), name = "Main Menu")
        self.push_screen("Main Menu")

if __name__ == '__main__':
    app = ArchiveGeneratorApp()
    app.run()