from fastapi import APIRouter, UploadFile, File, HTTPException
import base64
import google.generativeai as genai
import os
from dotenv import load_dotenv
import datetime

load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
model = genai.GenerativeModel("gemini-2.5-flash")

router = APIRouter()

@router.post("/recording-transcript")
async def recording_transcript(audio : UploadFile = File(None)):
    if audio is None:
        raise HTTPException(status_code=400, detail="No audio file provided")

    audio_data = await audio.read()

    # Saving File for Debugging
    os.makedirs("audio",exist_ok=True)
    with open(f"audio/{datetime.datetime.now()}.wav",'wb') as f:
        f.write(audio_data)

    encoded_audio = base64.b64encode(audio_data).decode('utf-8')

    prompt = [
        {
            "role": "user",
            "parts": [
                {
                    "text": (
                            "Make Minutes of the Meeting audio provided in proper markdown format. I don't want any extra metadata. Just the Minutes of the meeting should be given as the response. No comments, only minutes!!"
                    )
                }
            ]
        },
        {
            "role": "user",
            "parts": [
                {
                    "mime_type": "audio/wav",
                    "data": encoded_audio  # Base64 audio string
                }
            ]
        }
    ]

    response = model.generate_content(prompt)

    # Saving File for Debugging
    os.makedirs("minutes",exist_ok=True)
    with open(f"minutes/{datetime.datetime.now()}.md",'w') as f:
        f.write(response.text)
    
    return {"status": "success", "transcript": response.text}

