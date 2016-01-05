from .wire import decode_string

# map type_byte to message name
message_types = {
    0x01: "echo",
    0x02: "flush",
    0x03: "info",
    0x04: "set_option",
    0x21: "append_tx",
    0x22: "get_hash",
    0x23: "commit",
    0x24: "rollback",
    0x25: "add_listener",
    0x26: "rm_listener",
}

# return the decoded arguments of tmsp messages


class RequestDecoder():

    def __init__(self, reader):
        self.reader = reader

    def echo(self):
        return decode_string(self.reader)

    def flush(self):
        return

    def info(self):
        return

    def set_option(self):
        return decode_string(self.reader), decode_string(self.reader)

    def append_tx(self):
        return decode_string(self.reader)

    def get_hash(self):
        return

    def commit(self):
        return

    def rollback(self):
        return

    def add_listener(self):
        # TODO
        return

    def rm_listener(self):
        # TODO
        return
