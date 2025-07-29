# This is a minimal Python file required for App Engine Python runtime
# Since we're serving static files only, this file won't be executed

from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return 'Static files are served directly by App Engine'

if __name__ == '__main__':
    app.run(debug=True)
