from fastapi import APIRouter, UploadFile, File, HTTPException
import base64
import os
import datetime
from utils.gemini import model

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
                        "You are an advanced transcription system. Follow these rules strictly:\n\n"
                        "1. Input: An audio file in Hindi, English, or Hinglish (a natural mix of Hindi + English).\n\n"
                        "2. Task: Generate a transcript **exactly as spoken**, without translation, grammar correction, or language modification.\n"
                        "   - Hindi → always in Devanagari script (हिंदी).\n"
                        "   - English → always in English script.\n"
                        "   - Hinglish (mixed) → preserve exactly as spoken, don't normalize.\n\n"
                        "3. Preserve natural speech:\n"
                        "   - Keep fillers (umm, uh, arre, etc.), repetitions, informal words, and incomplete sentences.\n"
                        "   - Mark non-verbal sounds or events in brackets: [pause], [laughs], [music], [noise].\n\n"
                        "4. Speaker Handling:\n"
                        "   - Label speakers as Person 1, Person 2, etc.\n"
                        "   - If clear from context (e.g., names), use actual names consistently.\n\n"
                        "5. Long Audio Handling:\n"
                        "   - Break transcript into **chunks of 3–5 minutes** or logical speech segments.\n"
                        "   - Never cut off mid-sentence.\n"
                        "   - After each chunk, insert:\n"
                        "     --- [Transcript Continued] ---\n"
                        "   - Continue until the **entire audio is completely transcribed**.\n\n"
                        "6. Continuation / Resume Handling:\n"
                        "   - If audio is too long for one response, automatically continue in the next response from the exact point where the previous one stopped.\n"
                        "   - Always maintain speaker labels and formatting.\n\n"
                        "7. Output Format:\n"
                        "   - Use clean **Markdown format**.\n"
                        "   - Do NOT include summaries, metadata, explanations, or translations.\n"
                        "   - Only return the raw transcript."
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

