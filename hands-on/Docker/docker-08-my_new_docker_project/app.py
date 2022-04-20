# compose_flask/app.py

# import Flask and Redis libraries
from flask import Flask
from redis import Redis
import random

app = Flask(__name__)
redis = Redis(host='redis', port=6379)

# declare main route
@app.route('/')
def main():
    return 'Hi. In order to earn bonus points enter your name in the url. eg: /John'

# declare a route which gets the visitor's name. Every name has its own bonus points.
@app.route('/user/name')
def greet(name):
    bonus = random.randrange(1, 100)
    redis.incrby(name, bonus)
    return 'Hello %s. You have earned %d bonus points. Your total point is %s.' % (name, bonus, redis.get(name))

# run the flask application on the local development server.
if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)