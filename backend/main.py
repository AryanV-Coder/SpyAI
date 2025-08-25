from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import recording_transcript, chat

app = FastAPI()

# Allow CORS for frontend apps
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(recording_transcript.router)
app.include_router(chat.router)

@app.get('/start-server')
def start_server():
    print("✅ Server Started Successfully !!")
    return {'status':"success"}
