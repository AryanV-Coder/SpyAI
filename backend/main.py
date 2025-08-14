from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import recording_transcript

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
