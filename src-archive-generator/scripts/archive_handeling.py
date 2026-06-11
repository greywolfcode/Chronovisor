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

from datetime import datetime
from datetime import timezone

from pathlib import Path

import json

import zipfile

from scripts.id_handeler import IdType
from scripts.date_converter import datetime_to_string

class Person():
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email
    def __str__(self):
        return f"{self.name} ({self.email})"

class Message():
    def __init__(self, text: str, person: Person, time: datetime):
        self.text = text
        self.person = person
        self.time = time

class Archive():
    def __init__(self, uuid: str, type: IdType):
        self.uuid = uuid
        self.messages = []
        self.people = []
        self.type = type
        self.name = ""
        self.start_time = datetime.now(timezone.utc)
    def add_message(self, message: Message):
        self.messages.append(Message)
    def add_person(self, person: Person):
        self.people.append(person)

class GeneratedArchives():
    def __init__(self, uuid: str, group_info: str, messages: str):
        self.uuid = uuid
        self.group_info = group_info
        self.messages = messages

def export(archives: dict, output_folder:str | Path):

    generated_archives  = []

    for archive in archives:

        archive_id = archive.uuid.split(" ")[1] # get just number portion

        group_info = {
            "members": []
        }
        messages = {
            "messages": []
        }
        for person in archive.people:

            person_data = {
                "name": person.name,
                "email": person.email,
                "user_type": "Human"
            }
            group_info["members"].append(person_data)
        
        topic_ids = []

        for message in archive.messages:

            topic_id = IdType.gen_id(IdType.MESSAGE)
            topic_ids.append(topic_id)

            message_data = {
                "creator": {
                    "name": message.person.name,
                    "email": message.person.email,
                    "user_type": "Human"
                },
                "created_date": datetime_to_string(message.time),
                "text": message.text,
                "topic_id": topic_id,
                "message_id": "{archive_id}/{topic_id}/{topic_id}"
            }

            messages["messages"].append(message_data)
        
        group_info_json = json.dumps(group_info)
        messages_json = json.dumps(messages)

        generated_archives.append(group_info_json)
        generated_archives.append(messages_json)

    output_filename = "chronovisor-generator_takeout-" + datetime.now()

    with ZipFile(Path(output_folder, output_filename), 'w', zipfile.ZIP_DEFLATED) as output:

        for archive in generated_archives:
            output.writestr(Path(archive.uuid, "group_info.json"), archive.group_info)
            output.writestr(Path(archive.uuid, "messages.json"), archive.messages)