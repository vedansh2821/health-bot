# Medi-Bot — Disease Prediction & Hospital Recommendation Chatbot

A Flask web app with a rule-based chatbot that asks for your name, age and
symptoms, suggests a possible disease from a symptom dataset, and links to
nearby hospitals. It also has user registration/login (SQLite), a symptoms
browser, and a BMI calculator page.

> ⚠️ **Demo project, not a medical device.** Predictions come from a small
> dataset and cosine-similarity matching — they are rough guesses, not a
> diagnosis. Always consult a qualified doctor.

## Screenshots

Screenshots captured from the app running locally (`python app.py`):

![Medi-Bot home page](screenshots/home.png)

![Medi-Bot chatbot page](screenshots/chat.png)

> Note: the `static/` assets (CSS/JS/images) were deleted from the repo in
> 2024, so pages currently render unstyled. The chat screenshot shows the
> widget open with a message typed; the live exchange needs jQuery from the
> cdnjs CDN, which was unreachable in the sandbox where these were captured,
> so no bot reply is visible there — the `/ask` backend itself was verified
> separately (it returns the greeting and drives the name → age → symptoms
> flow).

## Stack

- **Backend:** Flask 3 + Flask-SQLAlchemy (SQLite)
- **ML / data:** pandas, scikit-learn (cosine similarity), DuckDuckGo Search
  (short disease summaries)
- **Frontend:** Jinja templates (Bootstrap-based theme, assets missing — see note above)

## How it works

1. `GET /user` starts a chat session; the bot collects name → age → choice.
2. **Predict Disease:** your symptoms are matched against `dataset.xlsx`
   (367 symptoms, 72 diseases) with `CountVectorizer` + cosine similarity in
   `predict_disease_from_symptom()` (`app.py`).
3. **Check Disease Symptoms:** `get_symtoms()` finds the symptoms recorded
   for a named disease.
4. `getDiseaseInfo()` adds a one-line web summary for the predicted disease
   (fails soft to an empty string when offline).
5. Login/register users are stored in SQLite (`instance/database.db`, created
   on first run — never committed).

## Project structure

```
app.py                  # Flask app: routes, chat state machine, prediction logic
msgConstant.py          # Chatbot greeting messages
requirements.txt        # Pinned dependencies
Dockerfile              # Container image (python:3.12-slim, port 3000)
classes/
  User.py               # BMI / BMR / calorie helpers (currently unused by app.py)
  Food.py               # Food item model (currently unused by app.py)
  Report.py             # Diet-report generator (currently unused by app.py)
dataset/
  training_data.csv     # Training data for the notebooks
  test_data.csv
dataset.xlsx            # Symptom → disease table used at runtime
food_list.csv
model/                  # Pre-trained .joblib models (decision tree, random
                        # forest, gradient boosting, naive Bayes) — currently
                        # unused: prediction uses cosine similarity, see above
notebook/               # Disease-prediction analysis notebook
templates/              # Jinja templates (index, login, register, bmi,
                        # diseases, index_auth, instructions, pred)
screenshots/            # Screenshots of the running app
```

## Run locally

```bash
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt

# Optional: set a real secret key (otherwise a dev-only default is used)
export SECRET_KEY="a-long-random-string"   # Windows: set SECRET_KEY=...

python app.py
```

Open <http://127.0.0.1:3000> — the app listens on port **3000**.

## Run with Docker

```bash
docker build -t medi-bot .
docker run -p 3000:3000 -e SECRET_KEY="a-long-random-string" medi-bot
```

## Known limitations

- **Passwords are stored in plaintext** in the `user` table and login
  compares them directly — do not reuse real passwords; this needs hashing
  (e.g. Werkzeug `generate_password_hash`) before any real deployment.
- **Chat state is global** (`userSession` / `all_result` dicts in `app.py`),
  so concurrent users share state. Fine for a local demo, not for production.
- The committed `database.db` was removed; the SQLite file is created fresh
  under `instance/` on first run and is git-ignored.
- `static/` (CSS/JS/images) is missing, so pages render without styling.
- The trained models in `model/` are not wired into the prediction path.
