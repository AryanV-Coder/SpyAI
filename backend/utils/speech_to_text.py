import speech_recognition as sr
from pydub import AudioSegment

def speech_to_text(audio_path):
    # 🎧 Convert to 16kHz mono WAV for transcription


    ################ CHECK THIS FILE AGAIN ###################
    audio = AudioSegment.from_file(audio_path, format="aac")
    audio = audio.set_channels(1).set_frame_rate(16000)
    audio.export(audio_path, format="wav")
    print("[✅] Converted audio to proper format")

    recognizer = sr.Recognizer()
    with sr.AudioFile(audio_path) as source:
        audio_data = recognizer.record(source)
    try:
        text = recognizer.recognize_google(audio_data)
    except sr.UnknownValueError:
        text = None
    return text
