from http.server import BaseHTTPRequestHandler, HTTPServer
import re

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        # return the path as the eth block number
        match_obj = re.match('/([\d]+)', self.path)
        if match_obj:
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            print(match_obj.group(1))
            self.wfile.write(match_obj.group(1).encode())
        else:
            pass

if __name__ == '__main__':
    server = HTTPServer(('', 8545), Handler)
    server.serve_forever()