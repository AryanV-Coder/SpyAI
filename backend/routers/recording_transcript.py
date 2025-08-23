from fastapi import APIRouter, UploadFile, File, HTTPException, Form
import base64
import os
import datetime
from utils.gemini import model
from utils.supabase_config import connect_postgres

router = APIRouter()

@router.post("/recording-transcript")
async def recording_transcript(
    audio: UploadFile = File(None), 
    recording_start_time: str = Form(None),
):
    if audio is None:
        raise HTTPException(status_code=400, detail="No audio file provided")

    print(f"📅 Recording start time received: {recording_start_time}")
    print(f"🎵 Audio file: {audio.filename}, size: {audio.size} bytes")

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
                        "1. Input: An audio file in Hinglish, English or Hindi.\n\n"
                        "2. Task: Generate a transcript **exactly as spoken**, without translation, grammar correction, or language modification.\n"
                        "   - Hindi → always in Devanagari script (हिंदी).\n"
                        "   - English → always in English script.\n"
                        "   - Hinglish (mixed) → preserve exactly as spoken, don't normalize.\n\n"
                        "3. Preserve natural speech:\n"
                        "   - Keep fillers (umm, uh, arre, etc.), repetitions, informal words, and incomplete sentences.\n"
                        "   - Mark non-verbal sounds or events in brackets: [pause], [laughs], [music], [noise].\n\n"
                        "4. Speaker Handling & Name Inference:\n"
                        "   - Initially label speakers as Person 1, Person 2, etc.\n"
                        "   - **CRITICAL: Name Inference Rule**\n"
                        "     * If a speaker says their name (e.g., 'Hello, my name is Aryan' or 'I am Priya'), immediately replace their speaker label with their actual name for ALL subsequent dialogue.\n"
                        "     * Example: If Person 1 says 'Hello, my name is Aryan', then replace 'Person 1:' with 'Aryan:' for all future statements by that speaker.\n"
                        "     * Similarly, if someone introduces another person ('This is Rahul' or 'Meet my friend Sarah'), use those names when that person speaks.\n"
                        "     * Once a name is identified, use it consistently throughout the entire transcript.\n"
                        "   - If names are unclear or not mentioned, continue using Person 1, Person 2, etc.\n\n"
                        "5. Long Audio Handling:\n"
                        "   - Break transcript into **chunks of 3–5 minutes** or logical speech segments.\n"
                        "   - Never cut off mid-sentence.\n"
                        "   - After each chunk, insert:\n"
                        "     --- [Transcript Continued] ---\n"
                        "   - Continue until the **entire audio is completely transcribed**.\n"
                        "   - **Maintain name consistency** across all chunks - if Person 1 becomes 'Aryan' in chunk 1, keep using 'Aryan' in all subsequent chunks.\n\n"
                        "6. Continuation / Resume Handling:\n"
                        "   - If audio is too long for one response, automatically continue in the next response from the exact point where the previous one stopped.\n"
                        "   - Always maintain speaker labels and formatting.\n"
                        "   - **Remember names** established in previous chunks.\n\n"
                        "7. Output Format:\n"
                        "   - Use clean **Markdown format**.\n"
                        "   - Do NOT include summaries, metadata, explanations, or translations.\n"
                        "   - Only return the raw transcript.\n\n"
                        "**EXAMPLE:**\n"
                        "Initial: Person 1: Hello, my name is Aryan. Who are you?\n"
                        "After name inference: Aryan: Hello, my name is Aryan. Who are you?\n"
                        "All future dialogue by that speaker: Aryan: [whatever they say next]"
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

    conn,cursor = connect_postgres()

    try :
        # Use parameterized query to prevent SQL injection
        query = "INSERT INTO transcripts(timestamp, transcript) VALUES (%s, %s)"
        cursor.execute(query, (recording_start_time, response.text))
        print("✅ Record Inserted Successfully !!")
    except Exception as e:
        print(e)

    conn.commit()
    cursor.close()
    conn.close()
    
    return {"status": "success", "transcript": response.text}