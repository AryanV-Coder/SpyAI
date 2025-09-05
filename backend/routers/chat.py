from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from utils.sql_query_generator import sql_query_generator
from utils.supabase_config import connect_postgres
from utils.speech_to_text import speech_to_text
from datetime import datetime


router = APIRouter()

@router.post('/chat')
async def chat(audio : UploadFile = File(None),text : str = Form(None)):

    # convert auddio to text, gemini ko text hi bhejna hai. Audio agar properly text me convert nahi hui to user ko batana hai ki auddio is not proper.
    if (audio is None and text is not None) :

        query = sql_query_generator(text)
        print(f"SQL QUERY GENERATED : {query}")

        conn,cursor = connect_postgres()

        try :
            cursor.execute(query)
            print("✅ Query Successful !!")

            result = cursor.fetchall()
            print(f"Response after select query : {result}")

            transcript = ''
            for row in result :
                transcript += row[0]

            print(f"Transcript : {transcript}")

        except Exception as e:
            print(e)
        
        cursor.close()
        conn.close()

        response = transcript_refiner(transcript = transcript, user_query = text)

        return {
            "status" : "success",
            "response" : response
        }
        # send this query to database here 
        # send the return transcript to transcript refiner with the user prompt.
    elif (audio is not None and text is None):

        os.makedirs("user_audio",exist_ok = true)
        content = await audio.read()
        audio_file_path = f"user_audio/{datetime.now()}"
        with open(audio_file_path,'wb') as file:
            file.write(content)
        
        ##### TRY BY JUST GIVING THE AUDIO FILE DIRECTLY TO THIS FUNCTION WITHOUT SAVING IT ANYWHERE
        audio_text = speech_to_text(audio_file_path)
        
        query = sql_query_generator(audio_text)
        print(f"SQL QUERY GENERATED : {query}")

        conn,cursor = connect_postgres()

        try :
            cursor.execute(query)
            print("✅ Query Successful !!")

            result = cursor.fetchall()
            print(f"Response after select query : {result}")

            transcript = ''
            for row in result :
                transcript += row[0]

            print(f"Transcript : {transcript}")

        except Exception as e:
            print(e)
        
        cursor.close()
        conn.close()

        response = transcript_refiner(transcript = transcript, user_query = text)

        return {
            "status" : "success",
            "response" : response
        }

    elif (audio is not None and text is not None):
        print ("BOTH AUDIO AND TEXT RECIEVED")
        raise HTTPException(status_code=400,detail = "Don't require both audio and text")
    else:
        print ("NOTHING RECIEVED")
        raise HTTPException(status_code=400,detail = "NOTHING RECIEVED")
