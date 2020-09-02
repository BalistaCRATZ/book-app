import csv
from flask import Flask, request, jsonify, Response
import xml.etree.ElementTree as ET
import requests

tag_names = {}
books = {}
tags_to_remove = ["30574", "8717", "11557", "5207", "22743", "22753", "4949", "11590", "17213", "18045", "30521", "10197", "10210", "20849", "15169", "32586"]

app = Flask(__name__)

def get_score(tags, sample_tags):

    score = 0

    for tag in tags:

        if tag in sample_tags:

            score += 1

    return score

def recommend(book_id):

    try:

        score = 0
        res_book_id = None

        #Check first tag in book

        master_key = next(iter(books[book_id]["tags"]))

        #Loop through all books with first tag being same, and calculate score

        for book in books:

            key = next(iter(books[book]["tags"]))

            if key == master_key:

                v = get_score(books[book]["tags"], books[book_id]["tags"])

                if v > score and book != book_id:

                    score = v
                    res_book_id = book

                else:

                    pass

        return res_book_id

    except KeyError:

        pass


def load_data():

    print("Loading data... ")

    #Loading the names and ids of the tags
    with open("tags.csv", encoding="utf-8") as f:

        reader = csv.DictReader(f)

        for row in reader:

            if row["tag_id"] not in tags_to_remove:

                tag_names[row["tag_id"]] = row["tag_name"]

    #Loading info about the books
    with open("books.csv", encoding="utf=8") as f:

        reader = csv.DictReader(f)

        for row in reader:

            books[row["goodreads_book_id"]] = {"title": row["title"],
                                                    "author": row["authors"],
                                                    "year": row["original_publication_year"],
                                                    "isbn": row["isbn"],
                                                    "image_url": row["image_url"],
                                                    "average_rating": row["average_rating"],
                                                    "tags": {}}
    #Loading the tags for each book
    with open("book_tags.csv", encoding="utf-8") as f:

        reader = csv.DictReader(f)

        for row in reader:

            if row["tag_id"] not in tags_to_remove:

                books[row["goodreads_book_id"]]["tags"][row["tag_id"]] = row["count"]


    print("Data loaded.")

load_data()

def get_user_book_id(name):

    key = "76XbzJQBNBFcQZHH2IVeaA"

    url = f"https://www.goodreads.com/search/index.xml?key={key}&q={name}"
    response = requests.get(url).text

    tree = ET.fromstring(response)

    book_id = tree.findall("./search/results/work/best_book/id")[0].text

    return book_id

@app.route("/", methods = ["GET"])
def get_recommended_book():

    if "name" in request.args:

        name = str(request.args["name"])

        id = get_user_book_id(name)

        book_id = recommend(id)

    try:

        return {"title": books[book_id]["title"],
                "author": books[book_id]["author"],
                "year": books[book_id]["year"],
                "isbn": books[book_id]["isbn"],
                "image_url": books[book_id]["image_url"],
                "average_rating": books[book_id]["average_rating"]}

    except KeyError:

        return {"message": "Sorry, book not found."}