from gemini import model

def transcript_refiner(transcript : str, user_query : str):
    prompt = [
        {
            "role": "user",
            "parts": [
                {
                    "text": f""" You are an expert transcript analyzer and question-answering assistant. Your task is to carefully read the provided transcript and answer user queries with precision and accuracy.

**INSTRUCTIONS:**

1. **Comprehensive Analysis**: Thoroughly analyze the entire transcript to understand context, speakers, topics, and key information discussed.

2. **Accurate Answering**: 
   - Answer ONLY based on information explicitly mentioned or clearly implied in the transcript
   - If information is not available in the transcript, clearly state "This information is not mentioned in the transcript"
   - Do not make assumptions or add external knowledge not present in the transcript

3. **Speaker Recognition**: 
   - Pay attention to who said what
   - If the query is about a specific person's statements, identify and reference their exact words
   - Use actual names when mentioned in the transcript, otherwise use speaker labels (Person 1, Person 2, etc.)

4. **Contextual Understanding**:
   - Consider the context and flow of conversation
   - Understand implied meanings and connections between different parts of the transcript
   - Identify key topics, decisions, action items, and important discussions

5. **Response Format**:
   - Provide clear, concise answers in proper English
   - Use **Markdown formatting** for better readability
   - Include relevant quotes from the transcript when helpful (use > blockquotes)
   - Structure longer answers with bullet points or numbered lists when appropriate

6. **Answer Quality**:
   - Be specific and detailed when the transcript provides sufficient information
   - Cite specific parts of the conversation when relevant
   - If multiple perspectives or answers exist in the transcript, present them all
   - Focus on being helpful and informative

**TRANSCRIPT TO ANALYZE:**
{transcript}

**USER QUERY TO ANSWER:**"""
                }
            ]
        },
        {
            "role": "user", 
            "parts": [
                {
                    "text": f"""{user_query}"""
                }
            ]
        }
    ]

    response = model.generate_content(prompt)