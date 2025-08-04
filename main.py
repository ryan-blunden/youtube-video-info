import json
import urllib.parse
from typing import Optional

import yt_dlp
from fastapi import APIRouter, FastAPI, HTTPException, Query, Request
from pydantic import BaseModel, field_validator


class VideoMeta(BaseModel):
    id: str
    title: str
    description: str
    thumbnail_url: str
    channel: str
    channel_url: str
    duration: int
    view_count: int


def get_video_meta(url) -> VideoMeta:
    ydl_opts = {
        "quiet": True,
        "no_warnings": True,
    }

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(url, download=False)

        return VideoMeta(
            id=info.get("id"),
            title=info.get("title"),
            description=info.get("description"),
            thumbnail_url=info.get("thumbnail"),
            channel=info.get("uploader"),
            channel_url=info.get("uploader_url"),
            duration=info.get("duration"),
            view_count=info.get("view_count"),
        )


app = FastAPI(
    title="YouTube Video Metadata API",
    description="A REST API to extract YouTube video metadata",
    version="0.1.0",
    docs_url="/docs",
    openapi_url="/openapi.json",  # OpenAPI spec
    servers=[
        {
            "url": "{BASE_URL}",
            "description": "Configurable server (set BASE_URL environment variable)",
            "variables": {
                "BASE_URL": {
                    "default": "http://localhost:8000",
                    "description": "Base URL for the API server (configure via BASE_URL environment variable)",
                }
            },
        }
    ],
)

# Create API router
api_router = APIRouter(prefix="/api")


class VideoInfoRequest(BaseModel):
    url: str

    @field_validator("url")
    @classmethod
    def validate_youtube_url(cls, v: str) -> str:
        """Validate that the URL is a valid YouTube URL."""
        if "youtube.com" not in v and "youtu.be" not in v:
            raise ValueError(f"Invalid URL: '{v}'. Please provide a valid YouTube URL.")
        return v


@api_router.get(
    "/video-metadata",
    response_model=VideoMeta,
    operation_id="get_youtube_video_metadata",
    description="Get YouTube video metadata such as title, description, and thumbnail using the full video URL",
)
async def get_youtube_video_info_get(
    request: Request,
    url: Optional[str] = Query(
        None,
        description="YouTube video URL",
        example="https://www.youtube.com/watch?v=ZHYK0m9rpB0",
    ),
):
    try:

        video_url = url
        if video_url:
            video_url = urllib.parse.unquote(video_url)

        if not video_url:
            try:
                body = await request.body()
                if body:
                    body_data = json.loads(body.decode())
                    video_url = body_data.get("url")
            except (json.JSONDecodeError, UnicodeDecodeError):
                pass

        if not video_url:
            raise HTTPException(
                status_code=400,
                detail="URL parameter is required either as query parameter or in request body.",
            )

        return get_video_meta(video_url)

    except HTTPException:
        raise
    except Exception as e:

        raise HTTPException(
            status_code=500, detail=f"Error retrieving video metadata: {str(e)}"
        )


app.include_router(api_router)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
