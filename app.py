from flask import Flask
import requests

app = Flask(__name__)

@app.route('/')
def hi():
    return "HI"

@app.route('/get-req', methods=['GET', 'POST'])
def get_data():
    response = requests.get('https://cat-fact.herokuapp.com/facts')
    # response = [item.get("item") for item in response.json()]
    return response.json()

if __name__ == '__main__':
    print(app.run(hi()))