import os

from fastapi import APIRouter, FastAPI, HTTPException, Query, Request

from youtube_service import VideoMeta, get_video_meta

BASE_URL = os.environ["BASE_URL"]

app = FastAPI(
    title="YouTube Video Metadata API",
    description="A REST API to extract YouTube video metadata",
    version="0.1.0",
    docs_url="/docs",
    openapi_url="/openapi.json",
    servers=[{"url": f"{BASE_URL}", "description": "API URL"}],
)

api_router = APIRouter(prefix="/api")


@api_router.get(
    "/video-metadata",
    response_model=VideoMeta,
    operation_id="get_video_metadata",
    description="Get YouTube video metadata such as title, description, and thumbnail by supplying the YouTube video URL.",
)
async def get_video_metadata(
    _: Request,
    url: str = Query(
        ...,
        description="YouTube video URL",
    ),
):
    try:
        return get_video_meta(url)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error retrieving video metadata: {str(e)}")


app.include_router(api_router)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
