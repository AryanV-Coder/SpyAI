from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from utils.sql_query_generator import sql_query_generator

router = APIRouter()

@router.post('/chat')
async def chat(audio : UploadFile = File(None),text : str = Form(None)):

    # convert auddio to text, gemini ko text hi bhejna hai. Audio agar properly text me convert nahi hui to user ko batana hai ki auddio is not proper.
    if (audio is None and text is not None) :
        query = sql_query_generator(text)
        # send this query to database here 
        # send the return trnascript to transcript refiner with the user prompt.
        pass
    elif (audio is not None and text is None):
        pass
    elif (audio is not None and text is not None):
        print ("BOTH AUDIO AND TEXT RECIEVED")
        raise HTTPException(status_code=400,detail = "Don't require both audio and text")
    else:
        print ("NOTHING RECIEVED")
        raise HTTPException(status_code=400,detail = "NOTHING RECIEVED")
