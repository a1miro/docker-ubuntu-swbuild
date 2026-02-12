#!/usr/bin/env python3
from http.server import SimpleHTTPRequestHandler, HTTPServer
import json
import os
from pathlib import Path

class BuildServerHandler(SimpleHTTPRequestHandler):
    # Load config mapping users to their projects folders
    with open('/etc/http-server-config.json', 'r') as f:
        USER_FOLDERS = json.load(f)
    
    def translate_path(self, path):
        # Extract username from path (e.g., /user1/...)
        parts = path.strip('/').split('/')
        if not parts or not parts[0]:
            return self.list_users()
        
        username = parts[0]
        if username in self.USER_FOLDERS:
            # Map to user's specific projects folder
            projects_path = self.USER_FOLDERS[username]
            # Remove username from path and append to projects folder
            remaining_path = '/'.join(parts[1:])
            full_path = os.path.join(projects_path, remaining_path)
            return os.path.abspath(full_path)
        
        return super().translate_path(path)
    
    def list_users(self):
        """Show available users on index page"""
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        html = '<html><body><h1>Available Build Folders</h1><ul>'
        for user in self.USER_FOLDERS:
            html += f'<li><a href="/{user}/">{user}</a></li>'
        html += '</ul></body></html>'
        self.wfile.write(html.encode())
        return None

if __name__ == '__main__':
    PORT = 8022
    server = HTTPServer(('0.0.0.0', PORT), BuildServerHandler)
    print(f'HTTP server running on http://0.0.0.0:{PORT}')
    server.serve_forever()
