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

import logging

from pathlib import Path

import json

from zipfile import ZipFile, ZIP_DEFLATED

from scripts.date_converter import date_to_path_string

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
        self.messages.append(message)
    def add_person(self, person: Person):
        self.people.append(person)

class GeneratedArchive():
    def __init__(self, uuid: str, group_info: str, messages: str):
        self.uuid = uuid
        self.group_info = group_info
        self.messages = messages

def export(archives: dict, output_folder:str | Path):

    logger = logging.getLogger(__name__)

    generated_archives  = []

    for archive in archives.values(): #keys are just the uuid

        archive_id = archive.uuid.split(" ")[1] # get just number portion
        logger.debug("Formatting archive " + archive_id)

        group_info = {
            "members": []
        }
        messages = {
            "messages": []
        }
        for person in archive.people:

            logger.debug("Formatting person " + str(person))

            person_data = {
                "name": person.name,
                "email": person.email,
                "user_type": "Human"
            }
            group_info["members"].append(person_data)
        
        topic_ids = []

        for message in archive.messages:
            logger.debug("Logging message")
            logger.info(vars(message))

            topic_id = IdType.gen_id(IdType.MESSAGE)
            topic_ids.append(topic_id)

            logger.debug("Created topic id " + topic_id)

            message_data = {
                "creator": {
                    "name": message.person.name,
                    "email": message.person.email,
                    "user_type": "Human"
                },
                "created_date": datetime_to_string(message.time),
                "text": message.text,
                "topic_id": topic_id,
                "message_id": f"{archive_id}/{topic_id}/{topic_id}"
            }

            messages["messages"].append(message_data)
        
        group_info_json = json.dumps(group_info)
        messages_json = json.dumps(messages)

        generated_archives.append(GeneratedArchive(archive.uuid, group_info_json, messages_json))

    output_filename = "chronovisor-generator_takeout-" + date_to_path_string(datetime.now()) + ".zip"

    output_path = Path(output_folder, output_filename)
    logger.info("Writing to: " + str(output_path))

    with ZipFile(output_path, 'w', ZIP_DEFLATED) as output:

        logger.info("Started writing archives...")
        for archive in generated_archives:
            logger.info("Writing archive " + archive.uuid)
            output.writestr(str(Path(archive.uuid, "group_info.json")), archive.group_info)
            output.writestr(str(Path(archive.uuid, "messages.json")), archive.messages)
        logger.info("Wrote all archives")