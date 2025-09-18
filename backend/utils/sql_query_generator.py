from utils.gemini import model
from datetime import datetime, timedelta

def sql_query_generator(user_query: str):
    """
    Generate SQL queries based on natural language user input to query transcript database.
    
    Args:
        user_query (str): Natural language query from user
        
    Returns:
        dict: Contains the generated SQL query and explanation
    """
    
    # Get current date for relative date calculations
    current_date = datetime.now().strftime("%Y-%m-%d")
    current_datetime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    prompt = [
        {
            "role": "user",
            "parts": [
                {
                    "text": f"""You are an expert SQL query generator for a transcript database. Your task is to convert natural language queries into precise SQL statements.

**DATABASE SCHEMA:**
- Table name: `transcripts`
- Columns:
  - `timestamp` (TIMESTAMP, PRIMARY KEY) - Format: YYYY-MM-DD HH:MM:SS
  - `transcript` (TEXT) - Contains the actual transcript text

**CURRENT DATE/TIME:** {current_datetime}

**QUERY GENERATION RULES:**

1. **Date/Time Understanding:**
   - "today" = {current_date}
   - "yesterday" = previous day
   - "this week" = current week (Monday to Sunday)
   - "last week" = previous week
   - "this month" = current month
   - Parse relative terms like "2 hours ago", "3 days ago", etc.

2. **SQL Query Patterns:**
   - For exact time: WHERE timestamp = 'YYYY-MM-DD HH:MM:SS'
   - For date range: WHERE timestamp BETWEEN 'start' AND 'end'
   - For partial matching: WHERE timestamp::date = 'YYYY-MM-DD' -> (for specific day)
   - For time patterns: WHERE timestamp LIKE 'YYYY-MM-DD%' or WHERE DATE(timestamp) = 'YYYY-MM-DD'

3. **Query Types to Handle:**
   - Time-based queries: "Show transcripts from yesterday"
   - Content-based queries: "Find transcripts mentioning 'meeting'"
   - Combined queries: "Show yesterday's transcripts about budget"
   - Range queries: "Transcripts between 2pm and 4pm today"

4. **How to handle content based queries:**
   - When searching for a specific content. Search using both Hindi and English.
   Eg. If you are going to generate a query like this - SELECT * FROM transcripts WHERE DATE(timestamp) = '2025-09-10' AND transcript ILIKE '%data structures%';
   Then generate it like this - SELECT * FROM transcripts WHERE DATE(timestamp) = '2025-09-10' AND (transcript ILIKE '%data structures%' OR transcript ILIKE '%डेटा स्ट्रक्चर्स%');

5. **Output Format:**
   - Return ONLY the SQL query, no explanations or extra text
   - Use proper PostgreSQL syntax
   - Always use single quotes for string literals
   - Include ORDER BY timestamp DESC for better readability

**EXAMPLES:**
- "yesterday's meeting" → SELECT * FROM transcripts WHERE DATE(timestamp) = CURRENT_DATE - INTERVAL '1 day' ORDER BY timestamp DESC;
- "transcripts from this morning" → SELECT * FROM transcripts WHERE DATE(timestamp) = CURRENT_DATE AND EXTRACT(hour FROM timestamp) < 12 ORDER BY timestamp DESC;

Now generate the SQL query for the following user request:"""
                }
            ]
        },
        {
            "role": "user", 
            "parts": [
                {
                    "text": user_query
                }
            ]
        }
    ]
    
    try:
        response = model.generate_content(prompt)
        sql_query = response.text.strip()
        
        # Clean up the response (remove any markdown formatting)
        if sql_query.startswith('```sql'):
            sql_query = sql_query.replace('```sql', '').replace('```', '').strip()
        elif sql_query.startswith('```'):
            sql_query = sql_query.replace('```', '').strip()
            
        return sql_query
        
    except Exception as e:
        return e