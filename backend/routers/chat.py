from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from utils.sql_query_generator import sql_query_generator

router = APIRouter()

@router.post('/chat')
async def chat(audio : UploadFile = File(None),text : str = Form(None)):
    if (audio is None and text is not None) :
        pass
    elif (audio is not None and text is None):
        pass
    elif (audio is not None and text is not None):
        print ("BOTH AUDIO AND TEXT RECIEVED")
        raise HTTPException(status_code=400,detail = "Don't require both audio and text")
    else:
        print ("NOTHING RECIEVED")
        raise HTTPException(status_code=400,detail = "NOTHING RECIEVED")
