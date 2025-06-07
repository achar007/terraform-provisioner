from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello, Flask Web App!"

if __name__ == '__main__':
    app.run(debug=True)
    #To listen on port 80 from the internet, set host to '0.0.0.0' and port to 80
    app.run(debug=True, host='0.0.0.0', port=80)