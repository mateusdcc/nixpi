#!/usr/bin/env python3
"""YouTube Transcript Extractor backed by youtube-transcript-api."""

import json
import re
import sys

def extract_video_id(url_or_id: str) -> str:
    """Extract YouTube 11-char video ID from URL or return raw ID."""
    match = re.search(r"(?:v=|\/embed\/|\/shorts\/|youtu\.be\/|\/v\/|^)([a-zA-Z0-9_-]{11})", url_or_id)
    return match.group(1) if match else url_or_id

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"status": "error", "message": "Missing video URL or ID argument"}))
        sys.exit(1)

    video_input = sys.argv[1]
    languages = sys.argv[2].split(",") if len(sys.argv) > 2 else ["en", "pt", "es"]
    video_id = extract_video_id(video_input)

    try:
        from youtube_transcript_api import YouTubeTranscriptApi
        transcript_list = YouTubeTranscriptApi.list_transcripts(video_id)
        
        try:
            transcript = transcript_list.find_transcript(languages)
        except Exception:
            transcript = transcript_list.find_generated_transcript(languages)
            
        data = transcript.fetch()
        full_text = " ".join([item.get("text", "") for item in data])
        print(json.dumps({
            "status": "ok",
            "video_id": video_id,
            "language": transcript.language_code,
            "is_generated": transcript.is_generated,
            "full_text": full_text,
            "segments": data[:50]
        }))
    except ImportError:
        print(json.dumps({
            "status": "error",
            "message": "youtube_transcript_api python module not found. Ensure python3Packages.youtube-transcript-api is in runtimePackages."
        }))
    except Exception as err:
        print(json.dumps({"status": "error", "message": str(err)}))

if __name__ == "__main__":
    main()
