import json
import os
import urllib.parse
from typing import Optional

from fastapi import APIRouter, FastAPI, HTTPException, Query, Request

from youtube_service import VideoMeta, get_video_meta

BASE_URL = os.environ["BASE_URL"]

app = FastAPI(
    title="YouTube Video Metadata API",
    description="A REST API to extract YouTube video metadata",
    version="0.1.0",
    docs_url="/docs",
    openapi_url="/openapi.json",
    servers=[
        {
            "url": f"{BASE_URL}",
            "description": "API URL"
        }
    ],
)

api_router = APIRouter(prefix="/api")


@api_router.get(
    "/video-metadata",
    response_model=VideoMeta,
    operation_id="get_video_metadata",
    description="Get YouTube video metadata such as title, description, and thumbnail by supplying the YouTube video URL in the url query parameter.",
)
async def get_video_metadata(
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

        raise HTTPException(status_code=500, detail=f"Error retrieving video metadata: {str(e)}")


app.include_router(api_router)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
