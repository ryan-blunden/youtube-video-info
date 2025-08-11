import os
import urllib.parse
from typing import Optional

from fastapi import HTTPException
from pydantic import BaseModel
from pyyoutube import Client


class VideoMeta(BaseModel):
    id: str
    title: str
    description: str
    thumbnail_url: str
    channel: str
    channel_url: str
    view_count: int


def _extract_video_id(video_url: str) -> Optional[str]:
    parsed = urllib.parse.urlparse(video_url)
    host = (parsed.netloc or "").lower()
    path = (parsed.path or "").strip("/")

    # youtu.be/<id>
    if host.endswith("youtu.be") and path:
        return path.split("/")[0]

    # youtube.com/watch?v=<id>, /shorts/<id>, /embed/<id>
    if "youtube.com" in host or "youtube-nocookie.com" in host:
        segments = path.split("/")
        if len(segments) >= 2 and segments[0] in {"shorts", "embed", "live"}:
            return segments[1]

        query = urllib.parse.parse_qs(parsed.query or "")
        if "v" in query and query["v"]:
            return query["v"][0]

    return None


def get_video_meta(url: str) -> VideoMeta:
    api_key = os.environ.get("YOUTUBE_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="Server misconfiguration: YOUTUBE_API_KEY is not set")

    video_id = _extract_video_id(url)
    if not video_id:
        raise HTTPException(status_code=400, detail="Invalid YouTube URL: unable to extract video ID")

    client = Client(api_key=api_key)

    resp = client.videos.list(
        video_id=video_id,
        parts=["snippet", "statistics"],
        return_json=True,
    )

    items = (resp or {}).get("items") or []
    if not items:
        raise HTTPException(status_code=404, detail="Video not found or unavailable")

    data = items[0]
    snippet = data.get("snippet", {})
    stats = data.get("statistics", {})

    # Best available thumbnail
    thumbs = snippet.get("thumbnails", {}) or {}
    thumb_url = None
    for key in ("maxres", "standard", "high", "medium", "default"):
        if key in thumbs and isinstance(thumbs[key], dict) and thumbs[key].get("url"):
            thumb_url = thumbs[key]["url"]
            break

    channel_id = snippet.get("channelId")
    channel_url = f"https://www.youtube.com/channel/{channel_id}" if channel_id else ""

    return VideoMeta(
        id=data.get("id") or video_id,
        title=snippet.get("title") or "",
        description=snippet.get("description") or "",
        thumbnail_url=thumb_url or "",
        channel=snippet.get("channelTitle") or "",
        channel_url=channel_url,
        view_count=int(stats.get("viewCount") or 0),
    )
