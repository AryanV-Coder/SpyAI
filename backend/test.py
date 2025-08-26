import requests
import os
from datetime import datetime

# Base URL for your FastAPI server
BASE_URL = "http://localhost:8000"  # Change port if different

def test_recording_transcript(audio_file_path):
    """
    Test the /recording-transcript endpoint
    """
    url = f"{BASE_URL}/recording-transcript"
    
    if not os.path.exists(audio_file_path):
        print(f"Error: Audio file not found at {audio_file_path}")
        return None
    
    try:
        # Prepare the file for upload
        with open(audio_file_path, 'rb') as audio_file:
            files = {
                'audio': ('audio.wav', audio_file, 'audio/wav')
            }
            
            data = {
                'current_time': datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            }
            
            print(f"Making request to: {url}")
            print(f"Uploading file: {audio_file_path}")
            print(f"Current time: {data['current_time']}")
            
            # Make the request
            response = requests.post(url, files=files, data=data)
            
            print(f"Response Status Code: {response.status_code}")
            
            if response.status_code == 200:
                result = response.json()
                print("✅ Success!")
                print(f"Status: {result.get('status', 'Unknown')}")
                print(f"Transcript Preview: {result.get('transcript', 'No transcript')[:200]}...")
                return result
            else:
                print("❌ Error!")
                print(f"Response: {response.text}")
                return None
                
    except requests.exceptions.ConnectionError:
        print("❌ Connection Error! Make sure your FastAPI server is running.")
        print("Run: uvicorn main:app --reload")
        return None
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return None

def test_server_health():
    """
    Test if the server is running
    """
    try:
        response = requests.get(f"{BASE_URL}/docs")
        if response.status_code == 200:
            print("✅ Server is running!")
            print(f"API docs available at: {BASE_URL}/docs")
            return True
        else:
            print("⚠️ Server responded but with unexpected status")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Server is not running!")
        print("Start your server with: uvicorn main:app --reload")
        return False

if __name__ == "__main__":
    print("🧪 Testing FastAPI Backend")
    print("=" * 50)
    
    # Test 1: Check if server is running
    print("\n1. Testing server health...")
    server_running = test_server_health()
    
    if server_running:
        # Test 2: Test audio transcript endpoint
        print("\n2. Testing /recording-transcript endpoint...")
        
        # Try to find an audio file to test with
        audio_files = [
            "audio/MFAIDS_lecture.aac",
            "audio/2025-08-15 00:56:08.020105.wav",
            "audio/2025-08-15 00:53:20.363768.wav"
        ]
        
        test_file = None
        for audio_file in audio_files:
            if os.path.exists(audio_file):
                test_file = audio_file
                break
        
        if test_file:
            result = test_recording_transcript(test_file)
        else:
            print("❌ No audio files found to test with.")
            print("Available audio files should be in the 'audio/' directory")
            print("Found files:")
            if os.path.exists("audio"):
                for f in os.listdir("audio"):
                    print(f"  - audio/{f}")
    else:
        print("\n⚠️ Cannot run endpoint tests - server not running")
        print("\nTo start the server, run:")
        print("uvicorn main:app --reload")