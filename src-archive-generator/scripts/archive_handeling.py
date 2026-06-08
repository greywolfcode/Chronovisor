class Message():
    def __init__(self, message: str):
        self.message = message

class Archive():
    def __init__(self, uuid: str):
        self.uuid = uuid
        self.messages = []
    def add_message(self, message: Message):
        self.messages.append(Message)
